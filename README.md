# Electronics Management System 🚀

A modern, high-performance **Electronics Inventory & Management System** built with **Flutter** and **Firebase**. This application provides a seamless experience for both customers and administrators to track, manage, and search for electronics inventory with real-time cloud synchronization.

## ✨ Features

### 🛒 For Users
- **Real-time Inventory**: Browse all available electronics items with live stock status.
- **Advanced Search**: Instantly find products by name using the optimized search bar.
- **Detailed Insights**: View comprehensive product details, including storage location and current pricing.
- **Modern UI**: A beautiful, responsive interface inspired by premium SaaS dashboards.

### 🛡️ Admin Panel
- **Secure Authentication**: Protected by Firebase Auth for exclusive administrative access.
- **Dynamic Dashboard**: 
  - **Live Stats**: View total items, total units in stock, and total inventory value at a glance.
  - **Glassmorphism Design**: High-impact visual statistics for better data monitoring.
- **Inventory Management**:
  - **Full CRUD**: Add, edit, and delete products effortlessly.
  - **Smart Pricing**: Automatically calculates selling price based on cost and markup.
  - **Low Stock Alerts**: Visual warnings for items with less than 5 units remaining.
  - **Profit Analysis**: Real-time margin percentage calculation for every product.

## 🛠️ Tech Stack

- **Frontend**: Flutter (Material 3 Design)
- **State Management**: Provider
- **Backend**: Firebase Cloud Firestore
- **Auth**: Firebase Authentication
- **CLI**: FlutterFire

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- A Firebase project set up at [Firebase Console](https://console.firebase.google.com/).

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/electronic-management-system.git
   cd electronic-management-system
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   Install the FlutterFire CLI and run:
   ```bash
   flutterfire configure
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```


## 📝 License
This project is licensed under the MIT License.

---
Developed with ❤️ by [Your Name]
