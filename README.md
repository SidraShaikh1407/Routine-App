# 📅 Routine - Daily Planner & Task Manager

A beautifully designed Flutter app to help you manage your daily routine and to-do tasks - all in one place.

---

## ✨ Features

### ✅ Tasks
- Add tasks with title and category (Work, Personal, Shopping, Health, General)
- Mark tasks as done / pending
- Delete tasks
- Filter tasks by: **All**, **Pending**, **Done**
- Summary bar showing total, pending, and done counts
- Tap any task to view full details

### 🕐 Daily Routine
- Full-day timeline view (5:30 AM → 10:30 PM)
- Auto-detects and highlights your **current activity**
- Progress bar tracking how many activities are done
- Add custom activities with time picker and icon
- Activities auto-sort by time
- Mark activities as done / delete them

### 📊 Stats
- Category-wise task breakdown
- Visual progress indicators

---

## 📱 Screenshots

> <img width="380" height="539" alt="image" src="https://github.com/user-attachments/assets/ecaa6b4b-7612-4562-94f4-a09f05314dcc" />
  <img width="380" height="539" alt="image" src="https://github.com/user-attachments/assets/7877c4ce-b3de-4e01-8527-150188f8a6bc" />
  <img width="380" height="539" alt="image" src="https://github.com/user-attachments/assets/0160adff-1e7b-45d2-9c55-b511e3d092a6" />



---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.41.6 or above)
- Android Studio or VS Code
- Android device or emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/routine.git

# Navigate into the project
cd routine/flutter_application_1

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build APK

```bash
flutter build apk --release
```

The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🛠️ Tech Stack

| Technology | Usage |
|------------|-------|
| **Flutter** | UI Framework |
| **Dart** | Programming Language |
| **Material 3** | Design System |
| **StatefulWidget** | State Management |

---

## 📁 Project Structure

```
lib/
└── main.dart
    ├── TodoApp              # Root app widget
    ├── MainNavScreen        # Bottom navigation controller
    ├── Task                 # Task data model
    ├── RoutineItem          # Routine item data model
    ├── HomeScreen           # Tasks tab
    ├── RoutineScreen        # Daily schedule tab
    ├── StatsScreen          # Statistics tab
    ├── _TaskCard            # Task list item widget
    └── _RoutineCard         # Routine timeline item widget
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
```

---

## 🎨 Design

- **Color scheme:** Indigo + Material 3
- **Theme:** Light with clean white surfaces
- **Navigation:** Bottom NavigationBar with 3 tabs
- **Timeline:** Vertical dot-and-line routine view

---

## 📋 Default Routine Schedule

| Time | Activity |
|------|----------|
| 5:30 AM | Wake up & freshen up |
| 6:00 AM | Morning exercise |
| 7:00 AM | Breakfast |
| 8:00 AM | Study / Work session 1 |
| 10:30 AM | Short break |
| 11:00 AM | Study / Work session 2 |
| 1:00 PM | Lunch |
| 2:00 PM | Rest / Nap |
| 3:00 PM | Study / Work session 3 |
| 5:30 PM | Evening walk |
| 7:00 PM | Dinner |
| 8:00 PM | Leisure / Screen time |
| 9:30 PM | Read / Wind down |
| 10:30 PM | Sleep |

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 👩‍💻 Author

**Sidra Shaikh**  
Made with ❤️ using Flutter
