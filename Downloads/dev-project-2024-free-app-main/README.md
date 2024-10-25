# FREE. - Flutter Mobile Application

A proof-of-concept app  based on the case study given to us in the SA&D Block. The concept behind this application is to create a seamless, integrated, social gathering scheduling platform designed for busy individuals i.e. family-oriented working professionals. This application, developed using the flutter framework for frontend development and Firebase for backend services,the app integrates with both the Google Calendar API and the Google People API to synchronise calendars and manage events with participants from your contacts.

## Getting Started: 

Before setting up the application, ensure you have the following software and tools installed:

- Git: Required for cloning the GitHub repository.
- Flutter SDK: Framework for building the mobile application.
- Android Studio: IDE for running and testing the app with an Android emulator.
- Firebase Account: For configuring the backend services, such as user authentication and database storage.
- Google Cloud Account: Required to access Google Calendar/People API and set up Google sign-in.

Necessity

Ensure that your computer and IDE, has Java ideally version 17, in your computer environment.


## Installation Instructions

### 1. Install Git

Download and install Git from <https://git-scm.com/>. This will be used to clone the project repository.


### 2. Install Flutter SDK

Follow the Flutter installation instructions for your operating system from the Flutter official website (https://flutter.dev/docs/get-started/install). Once installed, add Flutter to your system path so that it can be run from the command line.

Verify the installation by running:


```yaml
-- flutter doctor
```

When you run the Flutter Doctor command, it checks your environment for all the required dependencies to develop Flutter applications. The output includes information about the status of your Flutter SDK, Dart SDK, connected devices, and other tools. If there is [X] then it is recommended that you resolve the issue before continuing. 

[✓] Flutter: Indicates that the Flutter SDK is correctly installed, along with the version and any additional details.<br>
[✓] Android toolchain: Shows if the Android SDK is installed, and if there are any issues with it.<br>
[✓] Xcode: Verifies that Xcode is set up correctly for iOS development.<br>
[✓] Chrome: Confirms the presence of Chrome for web development.<br>
[✓] Android Studio: Checks if Android Studio and its plugins are installed and properly set up.<br>
[✓] Connected device: Lists available devices/emulators for testing.<br>
[✓] Network resources: Ensures the network settings and connections are adequate.

On Visual Studio code follow these steps to add the Flutter SDK to your path 

`ctrl+ shift+P` on the pop-up search `Add to path` and then you will get a pop-up that allows you to locate your SDK and add your VS code.

### 3. Install Android Studio
Download and install Android Studio from <https://developer.android.com/studio>. During installation, ensure that you install the Android SDK, Android Emulator, and Virtual Device components.

Open Android Studio and set up an Android Virtual Device (AVD) to use as an emulator:

- Go to Tools > AVD Manager.
- Create a new virtual device with suitable specifications (preferably a Pixel device and API level 35 or above).


Ensure you include the following SDK tools:

Android SDK
Android Emulator
Android Virtual Device (AVD)
Android SDK Build-Tools
SDK Platform Tools
Android SDK Command-line Tools


### 4. Clone the GitHub Classroom Repository

Navigate to the GitHub Classroom repository where the project is hosted. Clone the repository to your local machine 
using the following command:


git clone <https://github.com/suinformatics-binfhons/dev-project-2024-free-app>

Navigate to the project directory:

```yaml
cd <dev-project-2024-free-app>
```


### 5. Set Up Flutter Dependencies
Run the following command to get all the dependencies required by the project:

```yaml
flutter pub get

```

### 6. Configure Firebase Backend

##### Create a Firebase Project:

- Go to Firebase Console <https://console.firebase.google.com/>.
- Create a new project and set up Firebase for Android.
- Download the google-services.json file and place it in the android/app directory of your Flutter project.

#### Enable Firebase Services:

- Authentication: Enable Google sign-in by navigating to Authentication > Sign-in Method > Google, enable email & password.
- Firestore Database: Set up a Firestore database for storing event data and user information.
- Add Firebase to Flutter App:
- Modify the android/build.gradle and android/app/build.gradle files as per Firebase setup instructions.
- Add the required Firebase plugins to `pubspec.yaml`

  ```yaml
  - cupertino_icons: ^1.0.8
  - firebase_core: ^3.6.0
  - firebase_auth: ^5.3.1
  - cloud_firestore: ^5.4.4
  - table_calendar: ^3.0.0
  - http: ^1.2.2


### 7. Google API Integration

#### Step 1: Enable Google APIs
1. Go to the Google Cloud Console <https://console.developers.google.com/>.
2. Create a new project for the app and enable the following APIs:
   - Google Calendar API 
   - Google People API 

##### Step 2: Set Up OAuth Credentials
1. In the Google Cloud Console, navigate to APIs & Services > Credentials.
2. Create OAuth 2.0 Client ID credentials:
   - Select Application type: Android.
   - Provide the package name and the SHA-1 fingerprint of your Android app.
3. Download the credentials.json file and store it securely in your project. $we havent done that, just double check that this is true.

#### Step 3: Configure Flutter App for Google APIs
Add the following dependencies to your `pubspec.yaml` for accessing Google Calendar and Google People APIs:
dependencies:

```yaml
- google_sign_in: ^6.2.1
- googleapis: ^13.2.0
- googleapis_auth: ^1.6.0

```

### 8. Android OAuth Configuration
Step 1: Configure OAuth Consent Screen
1. In the Google Cloud Console, configure the OAuth consent screen:
   - Select External for the type.
   - Provide the necessary details, including the app's name, email, and scope of data access.
   - Google Calendar API (Scopes: Enable all scopes) 
   - Google People API (Scopes: Enable all scopes)

Step 2: Testing OAuth on Android Device
Ensure that you register the Android testing device under the OAuth 2.0 Credentials in the Google Cloud Console. When testing the application on Android devices, use the generated OAuth 2.0 Client ID for authentication with the necessary scopes.

. Running the Application on Android
1. Emulator Setup: Open Android Studio and create a virtual device using AVD Manager.
2. Connect Physical Device: Alternatively, connect an Android device via USB with USB debugging enabled.
3. Run the App: Use the following command to run the Flutter application:
flutter run

### 8. Additional Notes

- IDE Configuration: You may use Visual Studio Code with the Flutter extension as an alternative to Android Studio for development.




For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
