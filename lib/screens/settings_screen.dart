import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/tracker_provider.dart';
import '../core/theme/app_theme.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Settings',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: AppTheme.primaryPink,
              ),
              title: const Text(
                'Reset All Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Delete your logged periods.'),
              onTap: () {
                _showConfirmationDialog(context);
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Made by Anugerah',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Text(
              'Created with ❤️ to help track cycles seamlessly and privately.',
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _launchUrl('https://oneurl.live/anugerah'),
              icon: const Icon(Icons.link),
              label: const Text('Follow on Social'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryLavender,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _launchUrl('https://ko-fi.com/anugerah'),
              icon: const Icon(Icons.coffee),
              label: const Text('Donate / Buy me a coffee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Close',
            style: TextStyle(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Are you sure?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will permanently delete all your logged period data. You cannot undo this action.',
        ),
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ctx.read<TrackerProvider>().clearData();
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All data has been reset.'),
                  backgroundColor: AppTheme.primaryPink,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text('Delete Data'),
          ),
        ],
      ),
    );
  }
}
