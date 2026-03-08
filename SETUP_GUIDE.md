# Complete Setup Guide: Smart Helmet Navigation Display

This guide will help you set up the ESP32 navigation display for your Flutter smart helmet app.

## 📋 What You'll Need

### Hardware
- ESP32 Dev Kit V1
- ST7789 240x240 LCD Display
- Jumper wires (7 wires minimum)
- Breadboard (optional, for prototyping)
- Micro USB cable for ESP32
- Power source (ESP32 can be powered via USB or external 3.3V)

### Software
- Arduino IDE (latest version)
- Flutter development environment (already set up)
- WiFi network (same network for both ESP32 and phone)

## 🔧 Hardware Setup

### Step 1: Wiring the ST7789 Display

Connect the ST7789 to ESP32 Dev Kit V1 as follows:

```
ST7789 Pin → ESP32 Pin → Function
VCC        → 3.3V      → Power (IMPORTANT: Use 3.3V, NOT 5V!)
GND        → GND       → Ground
SCL        → GPIO 18   → SPI Clock
SDA        → GPIO 23   → SPI Data (MOSI)
RES        → GPIO 4    → Reset
DC         → GPIO 2    → Data/Command
BLK        → GPIO 22   → Backlight (optional)
```

### Step 2: Double-Check Connections
- Ensure all connections are secure
- Verify you're using 3.3V power (5V can damage the display)
- Check that wires are connected to the correct GPIO pins

## 💻 Software Setup

### Step 1: Install Arduino IDE
1. Download Arduino IDE from [arduino.cc](https://www.arduino.cc/en/software)
2. Install and open Arduino IDE

### Step 2: Add ESP32 Board Support
1. Go to **File → Preferences**
2. In "Additional Board Manager URLs", add:
   ```
   https://dl.espressif.com/dl/package_esp32_index.json
   ```
3. Go to **Tools → Board → Board Manager**
4. Search for "ESP32" and install "ESP32 by Espressif Systems"

### Step 3: Install Required Libraries
1. Go to **Sketch → Include Library → Manage Libraries**
2. Install these libraries (search and install each):
   - `TFT_eSPI` by Bodmer
   - `ArduinoJson` by Benoit Blanchon (version 6.x)
   - `WebSockets` by Markus Sattler

### Step 4: Configure TFT_eSPI Library
1. Find your TFT_eSPI library folder:
   - **Windows**: `Documents/Arduino/libraries/TFT_eSPI/`
   - **Mac**: `~/Documents/Arduino/libraries/TFT_eSPI/`
   - **Linux**: `~/Arduino/libraries/TFT_eSPI/`

2. Copy the `User_Setup.h` file from the `esp32_navigation_display` folder to the TFT_eSPI library folder, replacing the existing one.

### Step 5: Upload ESP32 Code
1. Open `esp32_navigation_display.ino` in Arduino IDE
2. **IMPORTANT**: Update WiFi credentials:
   ```cpp
   const char* ssid = "YOUR_WIFI_NETWORK_NAME";
   const char* password = "YOUR_WIFI_PASSWORD";
   ```
3. Select board: **Tools → Board → ESP32 Dev Module**
4. Select port: **Tools → Port → (your ESP32 port)**
5. Click **Upload** button

### Step 6: Monitor ESP32
1. Open **Tools → Serial Monitor**
2. Set baud rate to **115200**
3. Reset ESP32 - you should see:
   ```
   Smart Helmet Navigation Display Starting...
   Connecting to WiFi: YourNetworkName
   Connected! IP address: 192.168.1.XXX
   WebSocket server started on port 81
   ```
4. **Note down the IP address** - you'll need it for the app!

## 📱 Flutter App Setup

### Step 1: Update Dependencies
The app already has all required dependencies. If you need to update them:
```bash
flutter pub get
```

### Step 2: Connect to ESP32 Display
1. Run your Flutter app
2. Go to **Dashboard → Helmet Display Settings** (purple button)
3. Enter the ESP32 IP address you noted earlier
4. Tap **Connect**
5. You should see "Connected to ESP32 successfully!"

### Step 3: Test the Connection
1. In the Helmet Settings screen, tap **Test**
2. The ESP32 display should show test navigation data
3. If successful, you're ready to use navigation!

## 🧪 Testing Navigation

### Step 1: Start Navigation
1. Go to **Navigation** tab in the app
2. Search for a destination
3. Select a destination from the search results
4. Navigation should start automatically

### Step 2: Check ESP32 Display
The display should show:
- Current navigation instruction
- Distance to next turn
- Total trip distance
- Estimated time of arrival
- Connection status indicators

## 🔍 Troubleshooting

### Display Issues

**Problem**: Display is blank or shows garbage
- **Solution**: Check wiring, especially power (must be 3.3V)
- **Solution**: Verify TFT_eSPI configuration is correct
- **Solution**: Try different jumper wires

**Problem**: Display shows "Error" screen
- **Solution**: Check WiFi credentials in Arduino code
- **Solution**: Ensure ESP32 and phone are on same network

### Connection Issues

**Problem**: App can't connect to ESP32
- **Solution**: Check IP address is correct
- **Solution**: Ensure both devices on same WiFi network
- **Solution**: Check ESP32 Serial Monitor for errors
- **Solution**: Try restarting ESP32

**Problem**: Connection drops frequently
- **Solution**: Check WiFi signal strength
- **Solution**: Move ESP32 closer to router
- **Solution**: Check power supply stability

### Navigation Issues

**Problem**: No navigation data on display
- **Solution**: Start navigation in the Flutter app first
- **Solution**: Check connection status in Helmet Settings
- **Solution**: Try the Test button in Helmet Settings

## 🎨 Customization Options

### Change Display Colors
Edit these lines in the Arduino code:
```cpp
#define BG_COLOR TFT_BLACK          // Background
#define TEXT_COLOR TFT_WHITE        // Regular text
#define INSTRUCTION_COLOR TFT_CYAN  // Navigation instructions
#define DISTANCE_COLOR TFT_YELLOW   // Distance information
#define STATUS_COLOR TFT_GREEN      // Status indicators
#define WARNING_COLOR TFT_RED       // Warnings/errors
```

### Adjust Display Rotation
Change this line for different orientations:
```cpp
tft.setRotation(1); // 0=portrait, 1=landscape, 2=portrait flipped, 3=landscape flipped
```

### Modify Update Frequency
The app sends updates every 5 seconds. To change this, edit `navigation_service.dart`:
```dart
Timer.periodic(const Duration(seconds: 5), (timer) async {
```

## 🚀 Advanced Features

### Add Turn Arrows
You can enhance the display by adding directional arrows based on the navigation instruction text.

### Voice Announcements
Connect a small speaker to ESP32 and use text-to-speech libraries for audio navigation.

### Multiple Displays
The WebSocket server can handle multiple connections, so you could add additional displays.

## 📞 Support

If you encounter issues:

1. **Check Serial Monitor**: Always check the ESP32 Serial Monitor for error messages
2. **Verify Wiring**: Double-check all connections match the wiring diagram
3. **Test Components**: Test the display with simple TFT_eSPI examples first
4. **Network Issues**: Ensure both devices are on the same WiFi network
5. **Power Issues**: Verify stable 3.3V power supply to the display

## ✅ Success Checklist

- [ ] ESP32 connects to WiFi and shows IP address
- [ ] Display shows "Ready" screen with IP address
- [ ] Flutter app connects to ESP32 successfully
- [ ] Test button sends data to display
- [ ] Navigation data appears on display during navigation
- [ ] Connection indicators work properly
- [ ] Display updates in real-time during navigation

Congratulations! Your smart helmet navigation display is now ready to use! 🎉