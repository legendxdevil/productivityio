# 🌞 Productivio — Your Daily Productivity & Motivation Partner

**Productivio** is a Flutter-based productivity and motivation app designed to keep you focused and inspired.  
It combines daily task reminders, motivational quotes, and a functional home screen widget for quick access — all in one smooth and modern interface.

---

## 🚀 Features

- ⏰ **Daily Notifications** – Get inspiring quotes or reminders every morning.
- 💬 **Motivational Quotes Section** – Swipe through daily quotes.
- 📅 **Custom Reminders** – Set your own productivity notifications.
- 🧩 **Home Screen Widget** – Displays today’s quote and task status.
- 🎨 **Smooth UI/UX** – Built using Flutter + modern animations.
- ☁️ **Firebase Integration** – Store quotes & user preferences online (optional).

---

## 🧩 Tech Stack

| Component | Technology Used |
|------------|-----------------|
| Frontend | Flutter (Dart) |
| Notifications | flutter_local_notifications |
| Widget | Glance / Home Widget Package |
| Database | Firebase Firestore (optional) |
| Platform | Android Only |

---

## 🛠️ Setup Instructions

### 1. Clone Repository
```bash
git clone https://github.com/your-username/productivio.git
cd productivio
2. Install Dependencies
bash
Copy code
flutter pub get
3. Firebase (Optional)
Create a new Firebase project

Add an Android app → get google-services.json

Place it inside /android/app/

Enable Firestore if you want to manage quotes remotely

4. Permissions
Add the following in AndroidManifest.xml:

xml
Copy code
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
📁 Folder Structure
css
Copy code
lib/
│
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── quotes_screen.dart
│   ├── settings_screen.dart
│
├── widgets/
│   ├── quote_widget.dart
│   ├── task_widget.dart
│
├── services/
│   ├── notification_service.dart
│   ├── firebase_service.dart
│
└── utils/
    ├── quotes_data.dart
    ├── theme.dart
📱 Key Packages
yaml
Copy code
dependencies:
  flutter:
    sdk: flutter
  flutter_local_notifications: ^17.0.0
  home_widget: ^0.5.0
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
  google_fonts: ^6.0.0
🧠 Learning Outcomes
Implementing local notifications in Flutter

Creating a functional Android home widget

Managing quote data with Firestore / local list

Handling background tasks and smooth animations

▶️ Run the App
bash
Copy code
flutter run
Make sure you have an Android emulator or device connected.

📸 Screenshots (Add later)
Home	Notification	Widget

🏁 Future Enhancements
AI-generated motivational quotes

Google Calendar integration for reminders

Streak counter for daily productivity

Dark / Light theme toggle

👨‍💻 Author
Nand Kishor Soni
College Project | Built with Flutter for Android

📄 License
This project is open-source and can be used for educational or personal use.

yaml
Copy code

---

Agar tum chaho toh main iske liye  
➡️ `main.dart` + `notification_service.dart` + `quote_widget.dart`  
ka **starter Flutter code** bhi likh du — jisme ek working notification aur quote widget demo included ho.  

Kya tum chahte ho main ab **yeh functional code version** bana du taaki tum Android Studio me run kar sak