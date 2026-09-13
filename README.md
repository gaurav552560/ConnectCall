# 📞 ConnectCall

### Connect with anyone, anywhere.

A functional **1-to-1 audio and video calling application** built with Flutter for the Flutter Development Intern assignment.

ConnectCall provides real-time communication, Firebase authentication, Firestore-backed users and call history, and ZEGOCLOUD-powered audio/video calling.

---

## ✨ Features

### 🔐 Authentication
- User registration
- Email/password login
- Logout
- Authentication state management
- Splash screen

### 👥 Users & Contacts
- View registered users
- Search users by name
- User profile
- Online/offline presence
- Audio call button
- Video call button

### 📞 Audio Calling
- 1-to-1 audio calls
- Incoming call screen
- Accept/reject incoming calls
- Microphone mute/unmute
- Speaker control
- Call duration
- End call
- Call status handling

### 🎥 Video Calling
- 1-to-1 video calls
- Remote video
- Local camera preview
- Microphone mute/unmute
- Camera on/off
- Front/rear camera switching
- End call

### 📋 Call History
- Caller/callee information
- Audio/video call type
- Call date and time
- Call duration
- Completed calls
- Missed calls
- Declined calls
- Recent calls on Home screen

### 🔒 Permissions & Error Handling
- Microphone permission handling
- Camera permission handling
- Permission denied handling
- Permanently denied permission handling
- Open app settings for permanently denied permissions
- Call failure handling
- Offline/unavailable user handling
- Loading states
- Empty states

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Calling | ZEGOCLOUD |
| Push Notification Integration | Firebase Cloud Messaging + ZPNs |
| Permissions | permission_handler |
| State Management | StatefulWidget + setState |
| Backend | Firebase |

---

## 📦 Packages Used

```yaml
firebase_core
firebase_auth
cloud_firestore

zego_uikit_prebuilt_call
zego_uikit_signaling_plugin
zego_zpns

firebase_messaging
permission_handler
```

## Project Architecture
The project follows a simple service-based architecture that separates UI, data models, and business/integration logic.
```text
lib/
│
├── models/
│   ├── user_model.dart
│   └── call_model.dart
│
├── services/
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── call_service.dart
│   ├── permission_service.dart
│   └── zego_service.dart
│
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   │
│   ├── auth/
│   │   ├── auth_gate.dart
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   │
│   ├── home/
│   │   └── home_screen.dart
│   │
│   ├── contacts/
│   │   └── contacts_screen.dart
│   │
│   ├── profile/
│   │   └── profile_screen.dart
│   │
│   ├── call/
│   │   └── call_screen.dart
│   │
│   └── history/
│       └── call_history_screen.dart
│
└── main.dart
```

### Architecture Responsibilities

**Models**

- Define application data structures.
- `UserModel` represents users.
- `CallModel` represents call-history records.

**Services**

- `AuthService` → Firebase authentication.
- `UserService` → Firestore users and presence.
- `CallService` → Call history storage and retrieval.
- `PermissionService` → Camera and microphone permissions.
- `ZegoService` → ZEGOCLOUD initialization and call events.

**Screens**

- Handle UI, navigation and user interaction.
- Use local Flutter state with `StatefulWidget` and `setState`.

**Firestore Streams**

- Used for real-time user presence and call-history updates.

---

## 🔥 Backend

### Firebase

Firebase is used as the application's backend.

**Firebase Authentication**

- Handles user registration and login.
- Maintains authentication state.

**Cloud Firestore**

- Stores user information.
- Stores online/offline presence.
- Stores call-history records.

---

## 📡 Calling Technology

### ZEGOCLOUD

ZEGOCLOUD was selected for real-time communication because it provides:

- Prebuilt Flutter calling UI
- 1-to-1 audio calling
- 1-to-1 video calling
- Call invitation functionality
- Incoming call handling
- Call controls

This allows the application to focus on the product flow and Flutter implementation instead of building a complete WebRTC signaling system from scratch.

---

## 🔑 Permissions

The application requests permissions according to the selected call type.

### Audio Call

**Required permission:**

- Microphone

### Video Call

**Required permissions:**

- Camera
- Microphone

The application handles:

- Permission granted
- Permission denied
- Permanently denied
- Opening application settings

---

## 📱 Call Flow

```text
User selects contact
        ↓
Select Audio / Video
        ↓
Permission Check
        ↓
Calling
        ↓
Ringing
        ↓
Incoming Call
        ↓
Accept / Reject
        ↓
Connected
        ↓
In Call
        ↓
End Call
        ↓
Call History

```
The application also handles:
- Rejected
- Missed
- Failed
- Disconnected

  ### Call History

The application stores call records in Cloud Firestore.

Each call record contains:

| Field | Description |
|---|---|
| Caller | User who initiated the call |
| Receiver | User who received the call |
| Call Type | Audio or Video |
| Status | Ongoing, Completed, Declined, or Missed |
| Created Time | Time when the call was initiated |
| Started Time | Time when the call was connected |
| Ended Time | Time when the call ended |
| Duration | Total connected call duration |

Call history is displayed in the Calls screen and includes both incoming and outgoing calls.

Missed and declined calls are displayed with their respective status instead of showing a zero call duration.

---

### Main Screens

| Screen | Description |
|---|---|
| Splash Screen | Displays the application startup screen and checks authentication state |
| Login Screen | Allows existing users to sign in using email and password |
| Register Screen | Allows new users to create an account |
| Home Screen | Displays user information, recent calls, and quick actions |
| Contacts Screen | Displays registered users with search and audio/video call options |
| Profile Screen | Displays the current user's profile information and logout option |
| Calls Screen | Displays complete call history |
| Audio Call Screen | Provides 1-to-1 audio calling functionality |
| Video Call Screen | Provides 1-to-1 video calling functionality |

---

## Getting Started

Follow the steps below to run the ConnectCall project locally.

### Prerequisites

Make sure the following are installed:

- Flutter SDK
- Dart SDK
- Android Studio
- Android SDK
- Android emulator or physical Android device
- Git

---

### Clone the Repository

Clone the project using:

```bash
git clone https://github.com/gaurav552560/ConnectCall.git
```

### Firebase Configuration

The application uses Firebase Authentication and Cloud Firestore.

Firebase is used for:

- Email/password authentication
- User account management
- User profile data
- User online/offline presence
- Call history storage

For a new Firebase project, configure the following services:

1. Firebase Authentication
2. Email/Password sign-in provider
3. Cloud Firestore
4. Android application with the correct package name

The Android package name used by this project is:

```text
com.pmgaurav.connect_calls
```
The Firebase configuration file should be placed in the appropriate Android application directory:
```
android/app/google-services.json
```

### ZEGOCLOUD Configuration

The application uses ZEGOCLOUD UIKit for real-time 1-to-1 audio and video calling.

To configure ZEGOCLOUD:

1. Create a project in the ZEGOCLOUD Console.
2. Obtain the required App ID and App Sign.
3. Configure the App ID and App Sign in the application's ZEGOCLOUD service configuration.
4. Make sure the required ZEGOCLOUD packages are installed.
5. Run the application and test audio/video calling between registered users.

The project uses ZEGOCLOUD for:

- 1-to-1 audio calls
- 1-to-1 video calls
- Incoming call invitations
- Accept/reject call handling
- Call controls
- Call state management
- Real-time audio/video communication

> Do not publish or share the ZEGOCLOUD App Sign publicly. Use your own credentials when configuring the project.

---

### Run the Application

Connect an Android device or start an Android emulator and run:

```bash
flutter run
```

### To check connected devices:
```
flutter devices
```
## Build APK

### To generate a release APK:
```
flutter build apk --release
```
### The generated APK will be available at:
```
build/app/outputs/flutter-apk/app-release.apk
```
## Known Limitations

- The application currently focuses on 1-to-1 audio and video calling.
- Background/terminated-state incoming call notifications depend on the ZEGOCLOUD push notification configuration and device environment.
- The current implementation does not include a custom production backend server.
- Firebase Firestore is used for application data and call history.
- The release APK can be relatively large because ZEGOCLOUD includes native calling libraries and multiple Android architectures.
- The application is primarily tested on Android.
- Production deployment would require production Firebase security rules and properly secured release credentials.

---

## AI-Assisted Development

AI tools were used during development as development assistance.

AI assistance was used for:

- Understanding Flutter and Dart concepts
- Debugging compilation and runtime errors
- Understanding Firebase and Firestore integration
- Integrating ZEGOCLOUD calling functionality
- Designing call state and call history handling
- Debugging Android permissions and configuration
- Reviewing project structure and architecture
- Improving documentation and README formatting
- Troubleshooting Gradle and dependency-related issues

The application functionality, integration, testing, and final project decisions were reviewed and implemented as part of the project development process.

---

## Assignment Coverage

The project covers the major requirements of the calling application assignment.

### Authentication

- [x] User registration
- [x] User login
- [x] User logout
- [x] Authentication state handling
- [x] Splash screen

### Contacts and Users

- [x] Registered user list
- [x] Search users
- [x] User profile information
- [x] Online/offline status

### Audio Calling

- [x] Start 1-to-1 audio call
- [x] Incoming audio call
- [x] Accept call
- [x] Reject call
- [x] End call
- [x] Mute/unmute microphone
- [x] Speaker control
- [x] Calling state handling

### Video Calling

- [x] Start 1-to-1 video call
- [x] Incoming video call
- [x] Accept call
- [x] Reject call
- [x] End call
- [x] Camera on/off
- [x] Microphone mute/unmute
- [x] Switch camera

### Call States

- [x] Calling
- [x] Ringing
- [x] Connected
- [x] Ended
- [x] Declined
- [x] Missed
- [x] Completed

### Call History

- [x] Caller information
- [x] Receiver information
- [x] Audio/video call type
- [x] Call time
- [x] Call duration
- [x] Completed calls
- [x] Missed calls
- [x] Declined calls
- [x] Incoming and outgoing calls

### Permissions and Error Handling

- [x] Microphone permission
- [x] Camera permission
- [x] Permission denied handling
- [x] Permanently denied permission handling
- [x] Open application settings
- [x] Call failure handling
- [x] User unavailable/offline handling
- [x] Call rejection handling
- [x] Empty/loading/error states

### UI and Architecture

- [x] Clean Material 3 UI
- [x] Responsive layouts
- [x] Bottom navigation
- [x] Service-based architecture
- [x] Model classes
- [x] Firebase integration
- [x] ZEGOCLOUD integration

---

## Future Improvements

The following features can be added in future versions:

- Push notifications for incoming calls
- Reliable background and terminated-state incoming calls
- Custom backend/server-side call management
- Profile photo upload
- More advanced contact management
- Call search and filtering
- Call history pagination
- Better offline caching
- Block/unblock users
- Call notifications
- Group calling
- End-to-end production deployment
- Production Firebase security rules
- Release signing and Play Store deployment

---

## Repository

GitHub Repository:

https://github.com/gaurav552560/ConnectCall

The repository contains the complete Flutter project source code.

---

## Assignment Reference

This project was developed as a 1-to-1 audio and video calling application according to the provided Flutter calling application assignment requirements.

The implementation focuses on:

- Authentication
- User/contact management
- 1-to-1 audio calling
- 1-to-1 video calling
- Incoming call handling
- Call controls
- Call state management
- Call history
- Permissions
- Error handling
- Firebase backend integration
- ZEGOCLOUD real-time communication

---

## Conclusion

ConnectCall is a Flutter-based 1-to-1 audio and video calling application that combines Firebase for authentication, user data, presence, and call history with ZEGOCLOUD for real-time audio/video communication.

The project demonstrates Flutter UI development, Firebase integration, real-time communication, permission handling, call-state management, error handling, and structured application architecture.
