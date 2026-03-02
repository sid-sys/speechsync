import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../services/database_service.dart';
import '../services/llm_service.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum RecordingState { idle, recording, processing, done }

class AppState extends ChangeNotifier {
  // --- STATE ---
  final TextEditingController _controller = TextEditingController();
  TextEditingController get controller => _controller;

  String get transcription => _controller.text;
  final List<NoteModel> _notes = [];
  RecordingState _recordingState = RecordingState.idle;
  
  bool _isPro = false;
  int _rewriteUsage = 0;
  int _appendUsage = 0;
  bool _isOfflineMode = false;
  String? _activeProcessingTone;
  String? _detectedLanguage = "ENGLISH";
  String? _originalTranscription; // For undo

  // --- GETTERS ---
  List<NoteModel> get notes => List.unmodifiable(_notes);
  RecordingState get recordingState => _recordingState;
  bool get hasTranscription => _controller.text.isNotEmpty;
  bool get isPro => _isPro;
  bool get isRewritten => _originalTranscription != null;
  String? get activeProcessingTone => _activeProcessingTone;
  bool get isOfflineMode => _isOfflineMode;

  final AudioRecorder _recorder = AudioRecorder();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  String _lastLiveText = "";
  int? _insertionOffset;

  // --- METHODS ---
  Future<void> loadProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool('isPro') ?? false;
    _rewriteUsage = prefs.getInt('rewriteUsage') ?? 0;
    _appendUsage = prefs.getInt('appendUsage') ?? 0;
    notifyListeners();
  }

  Future<void> loadSettings() async {
     final prefs = await SharedPreferences.getInstance();
     _isOfflineMode = prefs.getBool('isOfflineMode') ?? false;
     notifyListeners();
  }

  Future<void> startRecording() async {
    debugPrint("--- Start Recording Attempt ---");
    if (await _recorder.hasPermission()) {
      debugPrint("Microphone Permission: GRANTED");
      
      // Initialize speech for live preview
      if (!_speechAvailable) {
        debugPrint("Initializing STT...");
        _speechAvailable = await _speech.initialize(
          onStatus: (status) => debugPrint('STT Status: $status'),
          onError: (error) => debugPrint('STT Error: $error'),
        );
        debugPrint("STT Available: $_speechAvailable");
      }

      _recordingState = RecordingState.recording;
      _lastLiveText = "";
      
      // Store current cursor for insertion
      final selection = _controller.selection;
      _insertionOffset = selection.isValid ? selection.baseOffset : _controller.text.length;
      
      notifyListeners();

      if (_speechAvailable) {
        debugPrint("Starting STT listening...");
        _speech.listen(
          onResult: (result) {
            if (_insertionOffset != null) {
              final text = _controller.text;
              final prefix = text.substring(0, _insertionOffset!);
              _controller.text = "$prefix ${result.recognizedWords}";
              _lastLiveText = result.recognizedWords;
            }
          },
        );
      }

      String? audioPath;
      if (!kIsWeb) {
        try {
          final dir = await getTemporaryDirectory();
          // Use .wav for better Windows stability
          audioPath = '${dir.path}${Platform.pathSeparator}temp_audio.wav';
          debugPrint("Target Audio Path (Absolute): $audioPath");
          
          final recordingFile = File(audioPath);
          if (recordingFile.existsSync()) {
            debugPrint("Old recording found, deleting...");
            recordingFile.deleteSync();
          }
        } catch (e) {
          debugPrint("Path Provider Error: $e. Falling back to local temp_audio.wav");
          audioPath = 'temp_audio.wav';
        }
      }
      
      try {
        debugPrint("Starting Recorder...");
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav, // Force wav for Windows
            sampleRate: 44100,
            bitRate: 128000,
          ), 
          path: audioPath ?? ''
        );
        debugPrint("Recorder Started successfully");
      } catch (e) {
        debugPrint("Recording Start Error: $e");
        _recordingState = RecordingState.idle;
        notifyListeners();
      }
    } else {
      debugPrint("Microphone Permission: DENIED");
    }
  }

  Future<void> stopRecording() async {
    debugPrint("--- Stop Recording Attempt ---");
    try {
      if (_speechAvailable) {
        debugPrint("Stopping STT...");
        await _speech.stop();
      }
      
      debugPrint("Stopping Recorder...");
      final path = await _recorder.stop();
      debugPrint("Recording stopped. Path: $path");
      
      _recordingState = RecordingState.processing;
      notifyListeners();

      if (path != null) {
        final file = File(path);
        if (file.existsSync()) {
          final size = file.lengthSync();
          debugPrint("Recording File Size: ${size / 1024} KB");
          
          if (size < 1000) {
             debugPrint("WARNING: Recording file is suspiciously small. Potential silent audio.");
          }

          final resultData = await LlmService.transcribeAudio(path);
          final result = resultData['text'];
          _detectedLanguage = "ENGLISH";

          debugPrint("Whisper Translation: $result");
          
          if (_insertionOffset != null) {
            final text = _controller.text;
            final prefix = text.substring(0, _insertionOffset!);
            final separator = prefix.isNotEmpty && !prefix.endsWith(' ') ? ' ' : '';
            _controller.text = "$prefix$separator$result";
            _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
          }
        } else {
          debugPrint("ERROR: Recording file does not exist at expected path: $path");
        }
      }
    } catch (e) {
      debugPrint("Transcription Error: $e");
    } finally {
      _recordingState = RecordingState.done;
      _insertionOffset = null;
      _originalTranscription = null;
      notifyListeners();
      saveNoteIfPro();
    }
  }

  void clearTranscription() {
    _controller.clear();
    _originalTranscription = null;
    notifyListeners();
  }

  Future<void> saveNote() async {
    final note = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: "Note ${DateFormat('MMM d').format(DateTime.now())}",
      content: transcription,
      createdAt: DateTime.now(),
    );
    await DatabaseService.instance.insertNote(note);
    await loadNotes();
    notifyListeners();
  }

  Future<void> loadNotes() async {
    final results = await DatabaseService.instance.getNotes();
    _notes.clear();
    _notes.addAll(results);
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await DatabaseService.instance.deleteNote(id);
    await loadNotes();
  }

  // --- PRO LOGIC ---
  bool canRewrite() => _isPro || _rewriteUsage < 3;
  bool canAppend() => _isPro || _appendUsage < 2;

  Future<void> changeTranscriptionTone(String tone) async {
    _activeProcessingTone = tone;
    notifyListeners();

    if (_originalTranscription == null) _originalTranscription = transcription;

    try {
      final rewritten = await LlmService.changeTone(_controller.text, tone);
      _controller.text = rewritten;
    } finally {
      _activeProcessingTone = null;
      notifyListeners();
    }
  }

  void undoRewrite() {
    if (_originalTranscription != null) {
      _controller.text = _originalTranscription!;
      _originalTranscription = null;
      notifyListeners();
    }
  }

  void incrementRewriteUsage() {
    if (!_isPro) {
      _rewriteUsage++;
      SharedPreferences.getInstance().then((p) => p.setInt('rewriteUsage', _rewriteUsage));
    }
  }

  Future<void> toggleOfflineMode(bool value) async {
    if (!_isPro) return;
    _isOfflineMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOfflineMode', value);
    notifyListeners();
  }

  Future<void> togglePro(bool value) async {
    _isPro = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPro', value);
    notifyListeners();
  }

  void saveNoteIfPro() {
     if (_isPro) saveNote();
  }

  Future<void> copyTranscription() async {
    if (transcription.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: transcription));
    }
  }

}
