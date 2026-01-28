

// This is a backward compatibility wrapper that maintains the old API
// while using the new Firebase-backed implementation

// Import and re-export the Firebase-based provider
export 'user_profile_provider_firebase.dart' show userProfileProvider;

// This file now simply re-exports the Firebase provider for backward compatibility
// All functionality has been moved to user_profile_provider_firebase.dart
