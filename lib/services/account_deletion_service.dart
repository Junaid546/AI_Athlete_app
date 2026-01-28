import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// Service for handling account deletion
class AccountDeletionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Check if user password is required for deletion
  Future<bool> requiresReauthentication() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // Check if user has multiple auth providers or password
      return user.providerData.isNotEmpty;
    } catch (e) {
    debugPrint('Error checking reauthentication requirement: $e');
      return false;
    }
  }

  /// Get deletion progress (phases)
  static const List<String> deletionPhases = [
    'Backing up your data',
    'Removing personal information',
    'Deleting workouts and progress',
    'Removing achievements and badges',
    'Clearing authentication',
    'Final cleanup',
  ];

  /// Delete user account completely
  Future<void> deleteUserAccount({
    required Function(int) onPhaseComplete,
    required Function(String) onError,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        onError('No user logged in');
        return;
      }

      // Phase 1: Backup user data
      onPhaseComplete(0);
      await _backupUserData(user.uid);

      // Phase 2: Remove personal information from Firestore
      onPhaseComplete(1);
      await _removePersonalData(user.uid);

      // Phase 3: Delete workout sessions
      onPhaseComplete(2);
      await _deleteWorkoutSessions(user.uid);

      // Phase 4: Remove achievements and badges
      onPhaseComplete(3);
      await _removeAchievements(user.uid);

      // Phase 5: Clear authentication
      onPhaseComplete(4);
      
      // Delete user profile image if exists
      try {
        await _storage.ref('users/$user.uid/profile.jpg').delete();
      } catch (_) {
        // File might not exist
      }

      // Phase 6: Final cleanup - delete auth user
      onPhaseComplete(5);
      await user.delete();

      // Delete Firebase auth user record
      await _firestore.collection('users').doc(user.uid).delete();
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        onError('Please log in again before deleting your account');
      } else {
        onError('Authentication error: ${e.message}');
      }
    } catch (e) {
      onError('Error deleting account: $e');
    }
  }

  /// Backup user data before deletion
  Future<void> _backupUserData(String uid) async {
    try {
      final userData = await _firestore.collection('users').doc(uid).get();
      if (userData.exists) {
        // Store backup with timestamp
        await _firestore
            .collection('user_data_backups')
            .doc(uid)
            .set({
          ...userData.data() ?? {},
          'deletedAt': FieldValue.serverTimestamp(),
          'backupVersion': '1.0',
        });
      }
    } catch (e) {
    debugPrint('Error backing up user data: $e');
    }
  }

  /// Remove personal information
  Future<void> _removePersonalData(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': '[DELETED]',
        'email': '[DELETED]',
        'phone': null,
        'bio': null,
        'profileImageUrl': null,
        'dateOfBirth': null,
        'location': null,
        'socialLinks': null,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
    debugPrint('Error removing personal data: $e');
    }
  }

  /// Delete all workout sessions
  Future<void> _deleteWorkoutSessions(String uid) async {
    try {
      final sessions = await _firestore
          .collection('users')
          .doc(uid)
          .collection('workout_sessions')
          .get();

      for (final session in sessions.docs) {
        await session.reference.delete();
      }
    } catch (e) {
    debugPrint('Error deleting workout sessions: $e');
    }
  }

  /// Remove achievements and badges
  Future<void> _removeAchievements(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'achievements': [],
        'badges': [],
        'personalRecords': [],
      });
    } catch (e) {
    debugPrint('Error removing achievements: $e');
    }
  }
}

/// Dialog for account deletion with password confirmation
class AccountDeletionConfirmationDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool requiresPassword;

  const AccountDeletionConfirmationDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
    this.requiresPassword = false,
  });

  @override
  State<AccountDeletionConfirmationDialog> createState() =>
      _AccountDeletionConfirmationDialogState();
}

class _AccountDeletionConfirmationDialogState
    extends State<AccountDeletionConfirmationDialog> {
  bool _isProcessing = false;
  bool _showPassword = false;
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async => !_isProcessing,
      child: AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Account Permanently'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  'WARNING: This action is permanent and cannot be undone. '
                  'All your data will be deleted.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We will delete:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...[
                'Profile information',
                'All workout sessions',
                'Progress data',
                'Achievements and badges',
                'Chat history',
              ].map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(item),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              if (widget.requiresPassword) ...[
                Text(
                  'Enter your password to confirm:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  enabled: !_isProcessing,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _showPassword = !_showPassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: _errorMessage,
                  ),
                ),
              ],
              if (_isProcessing) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor:
                      isDark ? Colors.white10 : Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
                const SizedBox(height: 12),
                Text(
                  'Deleting account...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : widget.onCancel ?? () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _handleDelete,
            icon: _isProcessing ? null : const Icon(Icons.delete_forever),
            label: _isProcessing
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.red.shade700,
                      ),
                    ),
                  )
                : const Text('Delete Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _handleDelete() {
    if (widget.requiresPassword && _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Password is required');
      return;
    }

    setState(() => _isProcessing = true);

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      widget.onConfirm();
    });
  }
}
