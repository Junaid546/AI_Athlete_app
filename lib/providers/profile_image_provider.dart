import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../providers/user_profile_provider_firebase.dart';

/// Profile image upload state
class ProfileImageState {
  final String? imageUrl;
  final bool isUploading;
  final String? error;
  final String? successMessage;

  ProfileImageState({
    this.imageUrl,
    this.isUploading = false,
    this.error,
    this.successMessage,
  });

  ProfileImageState copyWith({
    String? imageUrl,
    bool? isUploading,
    String? error,
    String? successMessage,
  }) {
    return ProfileImageState(
      imageUrl: imageUrl ?? this.imageUrl,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Profile image upload notifier
class ProfileImageNotifier extends StateNotifier<ProfileImageState> {
  final FirestoreService _firestoreService;
  final AuthService _authService;

  ProfileImageNotifier(this._firestoreService, this._authService)
      : super(ProfileImageState());

  /// Upload profile image
  Future<void> uploadProfileImage(File imageFile) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        state = state.copyWith(
          error: 'User not authenticated',
          isUploading: false,
        );
        return;
      }

      state = state.copyWith(isUploading: true, error: null, successMessage: null);

      final downloadUrl = await _firestoreService.uploadProfileImage(userId, imageFile);

      // Update user profile with new image URL
      await _firestoreService.updateUserProfileFields(userId, {
        'profileImageUrl': downloadUrl,
      });

      state = state.copyWith(
        imageUrl: downloadUrl,
        isUploading: false,
        successMessage: 'Profile image updated successfully!',
      );

    debugPrint('Profile image uploaded: $downloadUrl');
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: 'Failed to upload image: ${e.toString()}',
      );
    debugPrint('Error uploading profile image: $e');
    }
  }

  /// Delete profile image
  Future<void> deleteProfileImage() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        state = state.copyWith(error: 'User not authenticated');
        return;
      }

      state = state.copyWith(isUploading: true, error: null, successMessage: null);

      await _firestoreService.deleteProfileImage(userId);

      // Update user profile to remove image URL
      await _firestoreService.updateUserProfileFields(userId, {
        'profileImageUrl': null,
      });

      state = state.copyWith(
        imageUrl: null,
        isUploading: false,
        successMessage: 'Profile image deleted successfully!',
      );

    debugPrint('Profile image deleted');
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: 'Failed to delete image: ${e.toString()}',
      );
    debugPrint('Error deleting profile image: $e');
    }
  }

  /// Set image URL (from user profile)
  void setImageUrl(String? url) {
    state = state.copyWith(imageUrl: url);
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

/// Provider for profile image upload
final profileImageProvider =
    StateNotifierProvider<ProfileImageNotifier, ProfileImageState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  
  return ProfileImageNotifier(firestoreService, authService);
});
