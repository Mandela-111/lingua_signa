import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/video_conference_provider.dart';
import '../../domain/models/participant.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class CallView extends ConsumerWidget {
  const CallView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoConferenceNotifierProvider);
    
    return Stack(
      children: [
        // Main Video Grid
        _ParticipantGrid(participants: videoState.participants),
        
        // Local Video Preview
        const Positioned(
          top: 16,
          right: 16,
          child: _LocalVideoPreview(),
        ),
        
        // Translation Overlay
        if (videoState.participants.isNotEmpty)
          const Positioned(
            top: 60,
            left: 16,
            right: 100,
            child: _TranslationDisplay(),
          ),
        
        // Call Controls
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _CallControls(),
        ),
      ],
    );
  }
}

class _ParticipantGrid extends StatelessWidget {
  const _ParticipantGrid({required this.participants});
  
  final List<Participant> participants;

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const _EmptyCallView();
    }
    
    // Determine grid layout based on participant count
    final gridCount = participants.length;
    final crossAxisCount = gridCount == 1 ? 1 : gridCount <= 4 ? 2 : 3;
    
    return Container(
      color: Colors.black,
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 16 / 9,
        ),
        itemCount: participants.length,
        itemBuilder: (context, index) {
          return _ParticipantTile(participant: participants[index]);
        },
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant});
  
  final Participant participant;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Background
          if (participant.isVideoEnabled)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-157349635${participant.id.hashCode % 100}?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              color: Colors.grey[900],
              child: Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Text(
                    participant.name.split(' ').map((n) => n[0]).take(2).join(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          
          // Participant Info Overlay
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Audio Status
                  Icon(
                    participant.isAudioEnabled 
                        ? (participant.isMuted ? Icons.mic_off : Icons.mic)
                        : Icons.mic_off,
                    size: 12,
                    color: participant.isAudioEnabled && !participant.isMuted
                        ? Colors.white
                        : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  
                  // Participant Name
                  Flexible(
                    child: Text(
                      participant.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Video Status Indicator
          if (!participant.isVideoEnabled)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.videocam_off,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }
}

class _EmptyCallView extends StatelessWidget {
  const _EmptyCallView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Waiting for others to join...',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share the room ID with participants',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 1000.ms)
        .then()
        .fadeOut(duration: 1000.ms);
  }
}

class _LocalVideoPreview extends ConsumerWidget {
  const _LocalVideoPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoConferenceNotifierProvider);
    
    return GestureDetector(
      onTap: () => ref.read(videoConferenceNotifierProvider.notifier).toggleLocalVideo(),
      child: Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Stack(
          children: [
            // Local Video
            if (videoState.isLocalVideoEnabled)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.videocam_off,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            
            // Audio Status
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  videoState.isLocalAudioEnabled ? Icons.mic : Icons.mic_off,
                  size: 12,
                  color: videoState.isLocalAudioEnabled ? Colors.white : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranslationDisplay extends ConsumerWidget {
  const _TranslationDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    
    // Mock translation data
    const translations = [
      'Hello everyone, how are you?',
      'Nice to meet you all',
      'Thank you for joining the call',
    ];
    
    final currentTranslation = translations[DateTime.now().second % translations.length];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.translate,
                size: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                'Translation (${settings.selectedLanguage.code})',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            currentTranslation,
            style: TextStyle(
              color: Colors.white,
              fontSize: settings.translationTextSize.toDouble(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -0.5, end: 0)
        .fadeIn(duration: 300.ms);
  }
}

class _CallControls extends ConsumerWidget {
  const _CallControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoConferenceNotifierProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Audio Toggle
              _ControlButton(
                icon: videoState.isLocalAudioEnabled ? Icons.mic : Icons.mic_off,
                isActive: videoState.isLocalAudioEnabled,
                onTap: () => ref.read(videoConferenceNotifierProvider.notifier).toggleLocalAudio(),
                backgroundColor: videoState.isLocalAudioEnabled 
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.8),
              ),
              
              // Video Toggle
              _ControlButton(
                icon: videoState.isLocalVideoEnabled ? Icons.videocam : Icons.videocam_off,
                isActive: videoState.isLocalVideoEnabled,
                onTap: () => ref.read(videoConferenceNotifierProvider.notifier).toggleLocalVideo(),
                backgroundColor: videoState.isLocalVideoEnabled 
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.8),
              ),
              
              // End Call
              _ControlButton(
                icon: Icons.call_end,
                isActive: false,
                onTap: () => ref.read(videoConferenceNotifierProvider.notifier).leaveCall(),
                backgroundColor: Colors.red,
                size: 56,
              ),
              
              // Chat Toggle
              _ControlButton(
                icon: Icons.chat,
                isActive: false,
                onTap: () => _showChatOverlay(context),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
              
              // More Options
              _ControlButton(
                icon: Icons.more_vert,
                isActive: false,
                onTap: () => _showMoreOptions(context, ref),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showChatOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chat feature coming soon!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Real-time messaging with translation support',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showMoreOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OptionTile(
              icon: Icons.record_voice_over,
              title: 'Toggle Translation',
              subtitle: 'Enable/disable real-time translation',
              onTap: () => Navigator.of(context).pop(),
            ),
            _OptionTile(
              icon: Icons.share,
              title: 'Share Room',
              subtitle: 'Invite others to join',
              onTap: () => Navigator.of(context).pop(),
            ),
            _OptionTile(
              icon: Icons.settings,
              title: 'Call Settings',
              subtitle: 'Adjust quality and preferences',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.backgroundColor,
    this.size = 48,
  });
  
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70),
      ),
      onTap: onTap,
    );
  }
}