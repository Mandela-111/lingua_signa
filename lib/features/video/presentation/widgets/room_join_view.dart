import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/video_conference_provider.dart';

class RoomJoinView extends ConsumerStatefulWidget {
  const RoomJoinView({super.key});

  @override
  ConsumerState<RoomJoinView> createState() => _RoomJoinViewState();
}

class _RoomJoinViewState extends ConsumerState<RoomJoinView> {
  final _roomIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final videoState = ref.watch(videoConferenceNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final isConnecting = videoState.callState.name == 'connecting';
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.video_call,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Join Video Call',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with others and enjoy real-time sign language translation',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.2, end: 0),
          
          const SizedBox(height: 32),
          
          // Room Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Room ID',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _roomIdController,
                  enabled: !isConnecting,
                  decoration: const InputDecoration(
                    hintText: 'Enter room ID (e.g., ROOM123)',
                    prefixIcon: Icon(Icons.meeting_room),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room ID';
                    }
                    if (value.length < 4) {
                      return 'Room ID must be at least 4 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 24),
          
          // Settings Preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.settings,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current Settings',
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SettingRow(
                    icon: Icons.language,
                    label: 'Translation Language',
                    value: settings.selectedLanguage.name,
                  ),
                  _SettingRow(
                    icon: Icons.videocam,
                    label: 'Join with Video',
                    value: settings.joinWithVideo ? 'Enabled' : 'Disabled',
                  ),
                ],
              ),
            ),
          )
              .animate(delay: 400.ms)
              .fadeIn(duration: 600.ms)
              .slideX(begin: 0.2, end: 0),
          
          const Spacer(),
          
          // Join Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isConnecting ? null : _joinRoom,
              child: isConnecting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Connecting...'),
                      ],
                    )
                  : const Text('Join Room'),
            ),
          )
              .animate(delay: 600.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
  
  void _joinRoom() {
    if (_formKey.currentState?.validate() ?? false) {
      final roomId = _roomIdController.text.trim().toUpperCase();
      ref.read(videoConferenceNotifierProvider.notifier).joinRoom(roomId);
    }
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}