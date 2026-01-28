import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../providers/user_profile_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/profile_image_provider.dart';
import '../models/user_profile.dart';
import '../widgets/profile_header.dart';
import '../widgets/basic_info_section.dart';
import '../widgets/body_metrics_section.dart';
import '../widgets/training_profile_section.dart';
import '../widgets/achievements_badges_section.dart';
import '../widgets/personal_records_section.dart';
import '../widgets/coach_section.dart'; // Contains CoachSection and AthleteRosterSection
import '../widgets/social_section.dart';
import '../widgets/settings_appearance_section.dart';
import '../widgets/settings_notifications_section.dart';
import '../widgets/settings_workout_preferences_section.dart';
import '../widgets/settings_data_privacy_section.dart';
import '../widgets/settings_subscription_section.dart';
import '../widgets/settings_support_feedback_section.dart';
import '../widgets/settings_about_section.dart';
import '../widgets/settings_danger_zone_section.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleProfilePhotoTap() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (ref.read(userProfileProvider)?.profileImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final croppedFilePath = await _cropImage(File(image.path));
        if (croppedFilePath != null) {
          // Upload image to Firebase Storage using profileImageProvider
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading image...')),
          );
          
          try {
            await ref.read(profileImageProvider.notifier).uploadProfileImage(
              File(croppedFilePath),
            );
            
            if (!mounted) return;
            final imageState = ref.read(profileImageProvider);
            
            // Show result after upload completes
            if (imageState.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(imageState.successMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (imageState.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${imageState.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } catch (uploadError) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload failed: $uploadError'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Photo',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Profile Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    return croppedFile?.path;
  }

  void _removeProfilePhoto() {
    ref.read(profileImageProvider.notifier).deleteProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Profile & Settings'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Profile'),
                Tab(text: 'Settings'),
              ],
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Profile Tab
            RefreshIndicator(
              onRefresh: () async {
                // Refresh profile data
                await ref.read(userProfileProvider.notifier).refreshProfile();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(
                      userProfile: userProfile!,
                      onProfilePhotoTap: _handleProfilePhotoTap,
                      onEditProfile: () {
                        // Handle edit profile
                      },
                    ),
                    const SizedBox(height: 24),
                    BasicInfoSection(
                      userProfile: userProfile,
                      onFieldEdit: (field, value) {
                        // Handle field edit
                      },
                    ),
                    const SizedBox(height: 24),
                    BodyMetricsSection(
                      userProfile: userProfile,
                      onMeasurementTrack: () {
                        // Handle track measurement
                      },
                      onViewHistory: () {
                        // Handle view history
                      },
                    ),
                    const SizedBox(height: 24),
                    TrainingProfileSection(
                      userProfile: userProfile,
                      onFieldEdit: (field, value) {
                        // Handle field edit
                      },
                      onRoleSwitch: (role) {
                        // Handle role switch
                      },
                    ),
                    const SizedBox(height: 24),
                    const AchievementsBadgesSection(),
                    const SizedBox(height: 24),
                    PersonalRecordsSection(
                      userProfile: userProfile,
                      onViewAll: () {
                        // Handle view all
                      },
                      onViewHistory: () {
                        // Handle view history
                      },
                    ),
                    const SizedBox(height: 24),
                    if (userProfile.role == UserRole.athlete) ...[
                      CoachSection(
                        userProfile: userProfile,
                        onMessage: () {
                          // Handle message
                        },
                        onViewPlans: () {
                          // Handle view plans
                        },
                        onFindCoach: () {
                          // Handle find coach
                        },
                        onRequestChange: () {
                          // Handle request change
                        },
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      AthleteRosterSection(
                        onViewProfile: (id) {
                          // Handle view profile
                        },
                        onAddAthlete: () {
                          // Handle add athlete
                        },
                        onInviteByEmail: () {
                          // Handle invite by email
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    SocialSection(
                      userProfile: userProfile,
                      onFieldEdit: (field, value) {
                        // Handle field edit
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Save changes logic
                              ref.read(userProfileProvider.notifier).setProfile(userProfile);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile saved successfully')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Reset to default logic
                              ref.read(userProfileProvider.notifier).refreshProfile();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile reset to default')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Reset to Default'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Settings Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsAppearanceSection(
                    settings: settings,
                    onThemeModeChanged: (mode) => ref.read(settingsProvider.notifier).updateThemeMode(mode),
                    onAccentColorChanged: (color) => ref.read(settingsProvider.notifier).updateAccentColor(color),
                    onFontSizeChanged: (size) => ref.read(settingsProvider.notifier).updateFontSize(size),
                    onLanguageChanged: (lang) => ref.read(settingsProvider.notifier).updateLanguage(lang),
                  ),
                  const SizedBox(height: 24),
                  SettingsNotificationsSection(
                    settings: settings,
                    onNotificationsChanged: (notif) => ref.read(settingsProvider.notifier).updateNotifications(notif),
                  ),
                  const SizedBox(height: 24),
                  SettingsWorkoutPreferencesSection(
                    settings: settings,
                    onTrainingPreferencesChanged: (prefs) => ref.read(settingsProvider.notifier).updateTrainingPreferences(prefs),
                  ),
                  const SizedBox(height: 24),
                  SettingsDataPrivacySection(
                    settings: settings,
                    onDataSyncChanged: (enabled) => ref.read(settingsProvider.notifier).updateDataSync(enabled),
                    onOfflineModeChanged: (enabled) => ref.read(settingsProvider.notifier).updateOfflineMode(enabled),
                    onAnalyticsChanged: (enabled) => ref.read(settingsProvider.notifier).updateAnalytics(enabled),
                    onPersonalizedAIChanged: (enabled) => ref.read(settingsProvider.notifier).updatePersonalizedAI(enabled),
                    onDownloadData: () => {},
                    onDeleteAccount: () => {},
                  ),
                  const SizedBox(height: 24),
                  SettingsSubscriptionSection(
                    settings: settings,
                  ),
                  const SizedBox(height: 24),
                  SettingsSupportFeedbackSection(
                    settings: settings,
                  ),
                  const SizedBox(height: 24),
                  SettingsAboutSection(
                    settings: settings,
                  ),
                  const SizedBox(height: 24),
                  SettingsDangerZoneSection(
                    settings: settings,
                    onDeleteAccount: () => {},
                    onDownloadData: () => {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
