import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onStartChat;
  final VoidCallback onOpenSettings;

  const WelcomeScreen({
    super.key,
    required this.onStartChat,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = isDark ? Colors.white : Colors.grey[800];

    final bool? connectionStatus = settings.lastConnectionStatus;
    final bool isReady = connectionStatus == true;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Jobseeker AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 32),

              // Status Card
              if (connectionStatus == null)
                _buildStatusCard(
                  context,
                  'Connection Required',
                  'Please test your Ollama connection in settings.',
                  Icons.link_off,
                  Colors.orange,
                )
              else if (connectionStatus == false)
                _buildStatusCard(
                  context,
                  'Connection Failed',
                  'Could not reach ${settings.ollamaHost}. Check your IP and ensure Ollama is running.',
                  Icons.error_outline,
                  Colors.red,
                )
              else
                _buildStatusCard(
                  context,
                  'Connected',
                  'Verified connection to ${settings.ollamaHost}\nModel: ${settings.ollamaModel}',
                  Icons.check_circle_outline,
                  Colors.green,
                ),

              const SizedBox(height: 32),

              // Tombol Chat (Disembunyikan jika belum Ready)
              if (isReady) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: onStartChat,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Start Conversation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Tombol Settings selalu tampil
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings),
                  label: Text(connectionStatus == null ? 'Configure & Test' : 'Update Settings'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: !isReady ? Colors.orange : primaryColor,
                      width: !isReady ? 2 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
