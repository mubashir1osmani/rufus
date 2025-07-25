# Rufus - AI Personal Assistant for Students

Rufus is an iOS app designed to help students stay on top of their assignments with persistent, nagging reminders.

## Features

- **Assignment Tracking**: Keep track of all your assignments with due dates and subjects
- **Annoying Notifications**: Get persistent reminders that won't let you forget your assignments
- **Priority System**: Mark assignments as low, medium, high, or urgent priority
- **Dashboard View**: Get an overview of your assignments at a glance
- **Background Checking**: The app periodically checks for overdue assignments even when not in use

## Screenshots

*(Add screenshots here once the app is running)*

## Installation

1. Clone this repository
2. Open `rufus.xcodeproj` in Xcode
3. Build and run the project on your iOS device or simulator

## How It Works

### Assignment Management
- Add assignments with titles, descriptions, due dates, and subjects
- Set reminder dates for when you want to be notified
- Mark assignments as completed when finished
- Delete assignments you no longer need

### Notification System
Rufus is designed to be as annoying as possible to ensure you never forget an assignment:

1. **Main Reminder**: Notification at your specified reminder time
2. **Follow-up Reminder**: Additional notification 30 minutes after the main reminder
3. **Urgent Warning**: Final warning 1 hour before the due date
4. **Last Call**: Extreme reminder 10 minutes before the due date
5. **Overdue Alerts**: Persistent notifications for overdue assignments

### Annoying Messages
The app generates random, nagging messages like:
- "Hey lazy bones! Don't forget about [Assignment]! Get working!"
- "Stop procrastinating! [Assignment] needs your attention RIGHT NOW!"
- "I hate to interrupt your social media browsing, but [Assignment] won't complete itself!"

## Customization

In the Settings tab, you can:
- Enable/disable notifications
- Adjust the annoyance level
- Set how early you want reminders

## Technical Details

### Built With
- SwiftUI
- SwiftData
- UserNotifications framework
- BackgroundTasks framework

### Project Structure
```
rufus/
├── Models/
│   ├── Assignment.swift
│   └── NotificationItem.swift
├── Services/
│   ├── NotificationService.swift
│   ├── BackgroundTaskHandler.swift
│   └── AssignmentChecker.swift
├── Views/
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── Assignments/
│   │   ├── AssignmentsListView.swift
│   │   ├── AssignmentRowView.swift
│   │   └── AddAssignmentView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   ├── NotificationsView.swift
│   ├── MainTabView.swift
│   └── ContentView.swift
├── AppDelegate.swift
└── rufusApp.swift
```

## Contributing

Contributions are welcome! Feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by the need for students to stay on top of their assignments
- Designed to be intentionally annoying to combat procrastination
