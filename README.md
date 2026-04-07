# 🏋️‍♂️ AI Athlete Training App

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?style=for-the-badge&logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?style=for-the-badge&logo=firebase)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-blueviolet?style=for-the-badge)
![Gemini AI](https://img.shields.io/badge/Google%20Gemini-AI%20Powered-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

A production-grade, highly scalable Flutter application designed to revolutionize athletic training using state-of-the-art AI insights from Google Gemini. Featuring a pristine architecture based on Riverpod, Firebase integration, and a highly modular feature-first design philosophy.

---

## ⚡ Highlights

- **Ultra-Advanced Architecture**: Clean Architecture principles implemented with a modular, scalable structure perfectly tailored for enterprise-level applications.
- **AI-Driven Analytics**: Integrates Google Gemini AI to analyze raw workout data, compute insights, suggest recovery modalities, and autonomously construct micro & macrocycles for athlete progression.
- **Robust State Management**: Powered by **Riverpod** ensuring responsive state syncing and testable logic flow.
- **Firebase Infrastructure**: Highly secured, offline-first Firebase integrations (Firestore, Auth, Storage) mapping precisely strictly to the domain layer.
- **Secured API Integrations**: Employing `.env` best practices. No secrets exposed to version control.

---

## 🚀 Key Features

### 🔐 Authentication & Zero-Trust Security
- Multi-provider Firebase Auth (Email/Social integrations).
- Secured `.env` variable ingestion mapped to runtime configurations, fully separating sensitive keys from source code.

### 🤖 Generative AI Copilot & Insights
- **Conversational Coach**: Chat natively with an AI acting as a top-tier fitness coach.
- **Performance Predictions**: Daily tips & load-management advice.
- **Dynamic Training Generation**: Automatically generated routines adapted to real-time inputs.

### 📊 Real-Time Analytics & Progress Tracking
- Beautifully plotted charting utilizing `fl_chart`.
- Detailed volume metric tracking (sets x reps x weight).
- Automated reporting pipelines utilizing secure PDF generation.

---

## 🏗 Tech Stack & Dependencies

### Core Technologies
- **Framework**: `Flutter` SDK ^3.10.0
- **Language**: `Dart` ^3.x
- **State Management**: `flutter_riverpod`
- **Environment config**: `flutter_dotenv`

### Backend Services
- **Firebase Core / Auth / Storage / Cloud Firestore**
- **Google Generative AI**: Native APIs for Gemini Flash models

---

## ⚙️ How to Setup & Run locally

To ensure strict environment isolation and security, this project requires local environment configuration before building. Follow these instructions precisely.

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed & added to PATH.
- Android Studio / Xcode configured for your target platforms.
- Active Firebase Project
- Google Gemini API Key

### 2. Clone repository & Install Dependencies
```bash
git clone https://github.com/your-username/ai-athlete-training-app.git
cd ai-athlete-training-app
flutter pub get
```

### 3. Environment & Secrets Setup (CRITICAL ⚠️)
For security, all API keys must be injected via the `.env` file environment variables and are **not** hardcoded or tracked in Git.

1. Locate the `.env.example` file in the root directory.
2. Create a new file named exactly `.env` at the project root.
3. Copy the structure and populate with your own keys:
```env
# Gemini AI Configuration
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_API_KEY_CHAT=your_gemini_chat_api_key_here

# Firebase Configuration
FIREBASE_API_KEY=your_firebase_api_key_here
```
> Note: Without the correct `.env` variables mapped, Firebase initialization will fail and AI features will be locked. 

### 4. Running the App
Once configured, boot your target emulator/device and run:
```bash
flutter run
```

---

## 📂 Project Architecture

The project conforms to a heavily modulated **Feature-First Architecture**, significantly reducing tight coupling across modules.

```text
lib/
├── core/               # Platform level functionality, exceptions, theme configurations
├── models/             # Domain layer definitions & serialization
├── providers/          # Riverpod state notifiers and DI configurations
├── screens/            # UI presentation layer
├── services/           # External API & platform method channels
├── widgets/            # Globally reusable atomic UI components
├── firebase_options.dart # System initialized proxy mapping variables from .env
└── main.dart           # DI bootstrapper & application mount
```

---

## 🧠 Security & Compliance
- **No Hardcoded Keys**: All API connections utilize `flutter_dotenv`.
- **Git Ignore Safeguards**: `.env` is explicitly removed from version history.
- **Firebase Rules**: Ensure you configure secure Firestore rules prior to launching production servers.

---

## 👤 Author
**Junaid Tahir** 
*Advanced Flutter Developer & AI App Architect*

> Built to redefine what mobile experiences can be. Push the limits. 🚀
