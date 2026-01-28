import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../theme/app_theme.dart';

class SettingsDangerZoneSection extends StatefulWidget {
  final AppSettings settings;
  final VoidCallback onDeleteAccount;
  final VoidCallback onDownloadData;

  const SettingsDangerZoneSection({
    super.key,
    required this.settings,
    required this.onDeleteAccount,
    required this.onDownloadData,
  });

  @override
  State<SettingsDangerZoneSection> createState() => _SettingsDangerZoneSectionState();
}

class _SettingsDangerZoneSectionState extends State<SettingsDangerZoneSection> {
  bool _isDownloading = false;
  bool _isDeletingAccount = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dangerColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.dangerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppTheme.dangerColor),
              ),
              const SizedBox(width: 12),
              Text(
                'Danger Zone',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.dangerColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Download Data Section
          _DangerZoneItem(
            icon: Icons.download,
            title: 'Download Your Data',
            description: 'Export all your workout data, progress, and personal information as a file.',
            color: Colors.blue,
            isDark: isDark,
            isLoading: _isDownloading,
            onPressed: _isDeletingAccount ? null : () => _handleDownloadData(),
          ),
          const SizedBox(height: 16),
          
          // Delete Account Section
          _DangerZoneItem(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            description: 'Permanently delete your account and all associated data. This action cannot be undone.',
            color: AppTheme.dangerColor,
            isDark: isDark,
            isLoading: _isDeletingAccount,
            onPressed: _isDownloading ? null : () => _handleDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDownloadData() async {
    setState(() => _isDownloading = true);
    
    try {
      // Show progress indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Preparing your data...'),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // Call the download handler
      widget.onDownloadData();
      
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Your data has been downloaded successfully!'),
              ],
            ),
            backgroundColor: AppTheme.secondaryColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading data: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppTheme.dangerColor),
            const SizedBox(width: 8),
            const Text('Delete Account?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action is permanent and cannot be undone.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.dangerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'All your account data, workouts, progress, and personal information will be permanently deleted.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.dangerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'If you want to keep your data, download it before proceeding.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.dangerColor,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete Permanently',
              style: TextStyle(color: AppTheme.dangerColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed && mounted) {
      setState(() => _isDeletingAccount = true);
      
      try {
        // Show processing indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Deleting your account...'),
                ],
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        
        // Call the delete handler
        widget.onDeleteAccount();
        
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: $e'),
              backgroundColor: AppTheme.dangerColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isDeletingAccount = false);
        }
      }
    }
  }
}

class _DangerZoneItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isDark;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _DangerZoneItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isDark,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 2,
              ),
            )
          else
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Icon(Icons.arrow_forward, color: color, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
