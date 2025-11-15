<div align="center">

# 🧠 Productivio

Smart productivity app built with Flutter – reminders, events, notes (text, sketch, flowchart) and widgets in one place.

</div>

---

## ✨ Overview

**Productivio** is a personal productivity companion designed for Android. It brings together:

- **Motivational Home** – rotating quotes and prompts to keep you focused.
- **Strict Reminders** – multiple notifications before your deadline.
- **Smart Events** – one event per day with multi-offset alerts and widget pinning.
- **Powerful Notes** – text notes, sketch/pen notes, and flowchart/tree notes with PDF export.
- **Settings** – system/light/dark theme and utility actions.

The goal is to give you a simple but powerful daily hub that actually nudges you to get things done.

---

## 🧩 Features

### 🏠 Home
- Motivational quote cards with author.
- Designed to be a calm, focused starting screen.

### ⏰ Strict Reminders
- Create a reminder with:
  - Task title.
  - Emoji/category (💧 Water, 🏃 Exercise, 📚 Study, 🧠 Focus, ✨ Other).
  - Due date & time.
- Progressive notifications (e.g. **1h, 30m, 10m, 5m, 1m** before due).
- "Complete" action stops all pending notifications for that task.

### 📅 Smart Events
- Event details:
  - Title, topic/short detail.
  - Place & location/address/link.
  - Description.
  - Event time and optional reach time.
- **Smart rule**: only **one event per calendar day**.
- Custom multi-notification offsets (e.g. `24, 6, 1` hours before).
- Pin an event to the **Home Widget** with **days left**.

### 📝 Notes

#### 1. Text Notes
- Title + body.
- Attach images from **URL** and from **device gallery**.
- Horizontal preview strip of all images.
- Export note to **PDF** (title + body + attached images).

#### 2. Sketch / Pen Notes
- Canvas for finger drawing.
- Pen controls:
  - Multiple colors (black, blue, red, green).
  - Adjustable stroke width.
  - Clear canvas.
- Sketch is saved as an **image-backed note** (stored locally and shown as thumbnail).

#### 3. Flowchart / Tree Notes
- Node-based vertical tree layout:
  - Each node is a labeled box (Node 1, Node 2, ...).
  - Add/remove nodes dynamically.
- Good for:
  - Planning flows.
  - Topic breakdowns.
  - Simple mind-maps.

### ⚙️ Settings
- Theme mode toggle:
  - Follow system.
  - Light.
  - Dark.
- Utility actions moved from Home (e.g. test notification, widget refresh).
- Space for social media/contact links.

---

## 📸 Screenshots

> _Place your app screenshots in a `screenshots/` folder and link them here._

```markdown
![Home](screenshots/home.png)
![Reminders](screenshots/reminders.png)
![Events](screenshots/events.png)
![Notes](screenshots/notes.png)
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed (compatible with `sdk: ^3.9.2`).
- Android Studio / VS Code with Flutter & Dart plugins.
- A physical Android device or emulator (Android 13+ tested).

### Clone the repository

```bash
git clone https://github.com/legendxdevil/productivityio.git
cd productivityio
```

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

or build a debug APK:

```bash
flutter build apk --debug
```

Install the generated APK on your Android device and grant notification permissions when prompted.

---

## 🛠 Tech Stack

- **Framework:** Flutter (Material 3).
- **State management:** local `StatefulWidget` + `ValueNotifier` for theme.
- **Notifications:** `flutter_local_notifications` + `timezone`.
- **Home widget:** `home_widget`.
- **PDF & printing:** `pdf`, `printing`.
- **Images:** `image_picker` for gallery, network images via `Image.network`.

---

## 🗺 Roadmap

- [ ] Persistent storage for reminders, events and notes (e.g. Firestore/SQLite).
- [ ] More advanced flowchart editor (drag & drop nodes, connectors).
- [ ] Richer sketch tools (eraser, undo/redo, more colors).
- [ ] iOS support.
- [ ] More powerful widgets (next event, today’s tasks, quick note).

---

## 🤝 Contributing

Contributions and suggestions are welcome:

1. Fork the repo.
2. Create a feature branch: `git checkout -b feature/my-feature`.
3. Commit your changes: `git commit -m "feat: add my feature"`.
4. Push to the branch: `git push origin feature/my-feature`.
5. Open a Pull Request.

---

## 📄 License

This project is currently closed-source for personal use. You may fork and experiment for learning purposes, but please contact the author before using it in production or publishing on app stores.

