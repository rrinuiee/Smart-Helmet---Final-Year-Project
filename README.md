# Smart Helmet Navigation System

This repository contains the **navigation module** of a larger **Smart Helmet System** designed to improve rider safety and reduce distractions while navigating.

The system allows riders to view navigation instructions directly on a **helmet-mounted display**, eliminating the need to constantly check a mobile phone.

---

# Project Overview

The Smart Helmet project is a **team-developed system** that integrates navigation, safety monitoring, and smart vehicle control features into a motorcycle helmet.

This repository focuses specifically on the **navigation subsystem**, which includes:

* A custom mobile navigation application
* Communication with helmet hardware
* A helmet-mounted display powered by ESP32

---

# Navigation System

The navigation system allows riders to navigate using a dedicated mobile app while directions are displayed on a **helmet-mounted display**.

### Features

* Destination search
* Route calculation
* Turn-by-turn navigation
* Distance to next turn
* Estimated time of arrival (ETA)
* Real-time location tracking
* Wireless communication with ESP32
* Helmet display output

---

# System Architecture

```id="9zw26p"
Mobile Navigation App (Flutter)
        ↓
Navigation Instructions
        ↓
WiFi / WebSocket Communication
        ↓
ESP32 Dev Kit V1
        ↓
Helmet Mounted Display
```

---

# Hardware Components

* ESP32 DevKit V1
* ST7789 TFT Display (prototype display)
* Transparent OLED Display (planned helmet HUD)
* Helmet mounting frame

---

# Software Stack

### Mobile App

* Flutter
* OpenStreetMap / Flutter Map
* Geolocator
* HTTP APIs
* WebSocket communication

### Embedded System

* ESP32
* Arduino Framework
* TFT_eSPI Library
* ArduinoJson
* WebSockets

---

# Other Smart Helmet Modules

The navigation module is part of a larger **Smart Helmet System** developed as a team project.

Other implemented modules include:

### Drowsiness Detection

* Camera-based monitoring
* Eye tracking using MediaPipe

### Accident Detection

* Collision detection using MPU6050 sensor

### Emergency SOS System

* SMS alerts using GSM module
* GPS location sharing

### Smart Ignition Control

* Helmet detection using RSSI
* Communication between two ESP32 modules

Note:
Code for these modules is currently maintained separately by other team members and will be added in future updates if available.

---

# Repository Structure

```id="w34pmu"
smart-helmet-navigation
│
├── mobile-app
│   └── flutter_navigation_app
│
├── esp32-navigation-display
│   └── display_firmware
│
└── docs
```

---

# Setup

### Clone the Repository

```id="fh0rrv"
git clone https://github.com/rrinuiee/Smart-Helmet---Final-Year-Project
```

### Install Flutter Dependencies

```id="zrd06v"
flutter pub get
```

### Run the App

```id="2pn0dr"
flutter run
```

### Upload ESP32 Code

Upload the firmware in the `esp32-navigation-display` directory using Arduino IDE.

---

# Development Status

| Module                   | Status                    |
| ------------------------ | ------------------------- |
| Navigation App           | Completed                 |
| ESP32 Navigation Display | Working Prototype         |
| Helmet HUD Integration   | In Progress               |
| Drowsiness Detection     | Implemented (team module) |
| Accident Detection       | Implemented (team module) |
| SOS Alert System         | Implemented (team module) |
| Ignition Control         | Implemented (team module) |

---

# Author

Rinza Yunus

---

# License

MIT License
