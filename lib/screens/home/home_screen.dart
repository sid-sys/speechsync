import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bool isRecording = state.recordingState == RecordingState.recording;
    final bool isProcessing = state.recordingState == RecordingState.processing;
    final bool hasText = state.hasTranscription;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'SPEECHSYNC',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Colors.white24,
                ),
              ),
              const SizedBox(height: 30),
              
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: (isRecording || isProcessing)
                        ? _RecordingStateView(state: state)
                        : (hasText ? _TranscriptionView(state: state) : _IdleMicView(state: state)),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              if (hasText && !isRecording && !isProcessing)
                _ActionsGrid(state: state),
              
              const SizedBox(height: 80), // Navigation spacing
            ],
          ),
        ),
      ),
    );
  }
}

class _IdleMicView extends StatelessWidget {
  final AppState state;
  const _IdleMicView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'START SPEAKING',
          style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => state.startRecording(),
          child: Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10, width: 2),
              boxShadow: [
                 BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5),
              ],
            ),
            child: const Icon(Icons.mic_rounded, size: 48, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _RecordingStateView extends StatelessWidget {
  final AppState state;
  const _RecordingStateView({required this.state});

  @override
  Widget build(BuildContext context) {
    final bool isRecording = state.recordingState == RecordingState.recording;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isRecording) ...[
          const Text('LISTENING...', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () => state.stopRecording(),
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 3),
                boxShadow: [
                   BoxShadow(color: AppColors.accent.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 5),
                ],
              ),
              child: const Icon(Icons.stop_rounded, size: 50, color: AppColors.accent),
            ),
          ),
        ] else ...[
          const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3),
          const SizedBox(height: 40),
          const Text('ANALYZING...', style: TextStyle(color: Colors.white30, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        ],
      ],
    );
  }
}

class _TranscriptionView extends StatelessWidget {
  final AppState state;
  const _TranscriptionView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
           BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 10),
        ],
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: state.controller,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.6, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      hintText: 'Start speaking...',
                      hintStyle: TextStyle(color: Colors.white24),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -10, right: -10,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white24, size: 22),
              onPressed: () => state.clearTranscription(),
              tooltip: 'Clear',
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsGrid extends StatelessWidget {
  final AppState state;
  const _ActionsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _SimpleAction(icon: Icons.translate, label: 'Translate', onTap: () {}),
          _SimpleAction(icon: Icons.auto_fix_high, label: 'Rewrite', onTap: () {}),
          _SimpleAction(
            icon: Icons.copy_rounded, 
            label: 'Copy', 
            onTap: () {
              state.copyTranscription();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          ),
          _SimpleAction(icon: Icons.share, label: 'Share', onTap: () {}),
        ],
      ),
    );
  }
}

class _SimpleAction extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _SimpleAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: Colors.white70),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        onPressed: onTap,
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        side: const BorderSide(color: Colors.white10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}
