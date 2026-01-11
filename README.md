# Subscription Tracker

A simple yet powerful macOS menu bar application for managing your paid subscriptions efficiently. This app provides a visual calendar and customizable notifications to help you track and manage your subscription costs, ensuring you never miss a payment and stay on top of your recurring expenses.

![macOS 13.0+](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-green)

## Features

### 📅 Visual Calendar
- View all your subscription payments in an intuitive calendar interface
- See upcoming and current payment dates at a glance
- Color-coded subscriptions by category for easy identification
- Monthly navigation to plan ahead

### 🏷️ Smart Tagging System
- Mark subscriptions with custom tags (Annual, Trial, One-time, etc.)
- Create your own tags with custom colors
- Quick identification of important subscriptions
- Multi-tag support for each subscription

### 📊 Comprehensive Statistics
- Beautiful radial chart showing spending by category
- Real-time calculation of monthly and yearly costs
- Identify peak spending months
- Category breakdown with percentages
- Active vs. total subscription tracking

### 📂 Custom Categories
- Organize subscriptions into personalized categories
- Predefined categories included (Entertainment, Productivity, Cloud Storage, etc.)
- Custom color coding for visual organization
- Easy category management in settings

### ✅ Status Management
- Mark subscriptions as Active or Canceled
- Automatic exclusion of canceled subscriptions from statistics
- Track subscription history
- Quick status toggle

### 💾 Data Import/Export
- Export all subscription data to CSV format
- Import subscriptions from CSV files
- Perfect for backup and migration
- Compatible with spreadsheet applications

### 🔔 Smart Notifications
- Automatic notifications 3 days before payment
- Reminder 1 day before payment
- Notification on payment day
- Customizable notification preferences

### 🎨 Modern UI
- Clean, native macOS design
- Lives in your menu bar - always accessible
- Dark mode support
- Smooth animations and transitions

## Installation

### Prerequisites
- macOS 13.0 (Ventura) or later
- Xcode 14.0 or later

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/subscription-tracker.git
cd subscription-tracker
```

2. Open the project in Xcode:
```bash
open SubscriptionTracker/SubscriptionTracker.xcodeproj
```

3. Build and run:
   - Select the SubscriptionTracker scheme
   - Choose your Mac as the destination
   - Press `Cmd + R` to build and run

## Usage

### First Launch
1. The app icon will appear in your menu bar (calendar icon with a clock badge)
2. Click the menu bar icon to open the main interface
3. Grant notification permissions when prompted

### Adding a Subscription
1. Click the menu bar icon
2. Navigate to the "Subscriptions" tab
3. Click the "+" button
4. Fill in the subscription details:
   - Name (e.g., Netflix, Spotify)
   - Cost per billing cycle
   - Billing cycle (Weekly, Monthly, Quarterly, Semi-annually, Annually)
   - Next payment date
   - Category (optional)
   - Tags (optional)
   - Notes (optional)
5. Click "Save"

### Managing Categories
1. Click the menu bar icon
2. Navigate to the "Settings" tab
3. Select "Categories"
4. Click "+" to add a new category
5. Choose a name and color
6. Click "Save"

### Managing Tags
1. Click the menu bar icon
2. Navigate to the "Settings" tab
3. Select "Tags"
4. Click "+" to add a new tag
5. Choose a name and color
6. Click "Save"

### Viewing Statistics
1. Click the menu bar icon
2. Navigate to the "Statistics" tab
3. View:
   - Total monthly and yearly costs
   - Active subscription count
   - Spending breakdown by category (radial chart)
   - Peak spending month

### Using the Calendar
1. Click the menu bar icon
2. Navigate to the "Calendar" tab
3. Use the arrow buttons to navigate between months
4. View all payment dates color-coded by category
5. See total daily costs

### Exporting Data
1. Click the menu bar icon
2. Navigate to the "Subscriptions" tab
3. Click the export icon (square with arrow up)
4. Choose a location to save the CSV file
5. Click "Save"

### Importing Data
1. Click the menu bar icon
2. Navigate to the "Subscriptions" tab
3. Click the import icon (square with arrow down)
4. Select a CSV file
5. Click "Open"

## CSV Format

The CSV export/import uses the following format:

```csv
Name,Cost,Billing Cycle,Next Payment Date,Status,Category,Tags,Notes
Netflix,15.99,Monthly,12/15/25,Active,Entertainment,Annual,Family plan
Spotify,9.99,Monthly,12/10/25,Active,Music & Audio,Trial,Premium
```

## Project Structure

```
SubscriptionTracker/
├── SubscriptionTracker.xcodeproj/
│   └── project.pbxproj
└── SubscriptionTracker/
    ├── App/
    │   ├── SubscriptionTrackerApp.swift    # Main app entry point
    │   └── AppDelegate.swift                # Menu bar integration
    ├── Models/
    │   └── Subscription.swift               # Data models
    ├── Views/
    │   ├── MainView.swift                   # Main container view
    │   ├── SubscriptionListView.swift       # Subscription list
    │   ├── SubscriptionEditView.swift       # Add/Edit subscription
    │   ├── CalendarView.swift               # Calendar interface
    │   ├── StatisticsView.swift             # Statistics dashboard
    │   └── SettingsView.swift               # Settings & categories
    ├── Services/
    │   ├── DataManager.swift                # Data persistence
    │   ├── NotificationManager.swift        # Notification handling
    │   └── CSVManager.swift                 # CSV import/export
    ├── Resources/
    │   └── Assets.xcassets/                 # App icons & assets
    ├── Info.plist
    └── SubscriptionTracker.entitlements
```

## Architecture

The app follows a clean MVVM-like architecture:

- **Models**: Define the data structures (Subscription, Category, Tag)
- **Views**: SwiftUI views for the user interface
- **Services**: Business logic and data management
  - `DataManager`: Handles data persistence using UserDefaults and JSON encoding
  - `NotificationManager`: Manages local notifications for payment reminders
  - `CSVManager`: Handles CSV import/export functionality

## Data Persistence

Subscription data is stored locally using UserDefaults with JSON encoding. Data includes:
- All subscriptions (active and canceled)
- Custom categories
- Custom tags

## Notifications

The app schedules three types of notifications for each active subscription:
1. **3 days before**: Early warning
2. **1 day before**: Final reminder
3. **On payment day**: Day-of notification

Notifications are automatically rescheduled when:
- Subscriptions are added or modified
- The app is launched
- Payment dates are updated

## Privacy

- All data is stored locally on your Mac
- No data is sent to external servers
- No analytics or tracking
- Your subscription information stays private

## Requirements

- macOS 13.0 (Ventura) or later
- 50 MB free disk space
- Notification permissions (optional, but recommended)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and AppKit
- Uses SF Symbols for icons
- Inspired by the need for better subscription management

## Support

If you encounter any issues or have suggestions:
- Open an issue on GitHub
- Check existing issues for solutions
- Contribute improvements via Pull Requests

## Roadmap

Future enhancements under consideration:
- [ ] iCloud sync between devices
- [ ] Widgets for quick overview
- [ ] Currency conversion support
- [ ] Recurring notification customization
- [ ] Advanced filtering and search
- [ ] Subscription sharing/splitting
- [ ] Budget alerts and limits
- [ ] Historical spending graphs
- [ ] Receipt attachment support

---

**Made with ❤️ for better subscription management**
