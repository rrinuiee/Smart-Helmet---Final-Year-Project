import 'package:flutter/material.dart';

class QuickActionButtons extends StatelessWidget {
  final VoidCallback onNavigationPressed;
  final VoidCallback onSafetyPressed;
  final VoidCallback onSOSPressed;
  final VoidCallback? onHelmetSettingsPressed;

  const QuickActionButtons({
    super.key,
    required this.onNavigationPressed,
    required this.onSafetyPressed,
    required this.onSOSPressed,
    this.onHelmetSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Navigation',
                Icons.navigation,
                Colors.blue,
                onNavigationPressed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Safety',
                Icons.security,
                Colors.orange,
                onSafetyPressed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'SOS',
                Icons.emergency,
                Colors.red,
                onSOSPressed,
              ),
            ),
          ],
        ),
        if (onHelmetSettingsPressed != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              context,
              'Helmet Display Settings',
              Icons.display_settings,
              Colors.purple,
              onHelmetSettingsPressed!,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}