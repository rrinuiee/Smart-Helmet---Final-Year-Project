# ESP32 Navigation Display for Smart Helmet

This project displays navigation information from the Flutter app on an ST7789 LCD connected to an ESP32 Dev Kit V1.

## Hardware Requirements

- ESP32 Dev Kit V1
- ST7789 240x240 LCD Display
- Jumper wires
- Breadboard (optional)

## Wiring Diagram

Connect the ST7789 display to ESP32 as follows:

| ST7789 Pin | ESP32 Pin | Description |
|------------|-----------|-------------|
| VCC        | 3.3V      | Power supply |
| GND        | GND       | Ground |
| SCL        | GPIO 18   | SPI Clock |
| SDA        | GPIO 23   | SPI Data (MOSI) |
| RES        | GPIO 4    | Reset |
| DC         | GPIO 2    | Data/Command |
| BLK        | GPIO 22   | Backlight (optional) |

## Software Requirements

### Arduino IDE Setup

1. Install Arduino IDE
2. Add ESP32 board support:
   - Go to File > Preferences
   - Add this URL to Additional Board Manager URLs: 
     `https://dl.espressif.com/dl/package_esp32_index.json`
   - Go to Tools > Board > Board Manager
   - Search for "ESP32" and install "ESP32 by Espressif Systems"

3. Install required libraries:
   - **TFT_eSPI**: For ST7789 display control
   - **ArduinoJson**: For parsing JSON data from Flutter app
   - **WebSockets**: For communication with Flutter app

### Library Installation

1. Open Arduino IDE
2. Go to Sketch > Include Library > Manage Libraries
3. Search and install:
   - `TFT_eSPI` by Bodmer
   - `ArduinoJson` by Benoit Blanchon
   - `WebSockets` by Markus Sattler

### TFT_eSPI Configuration

1. After installing TFT_eSPI, you need to configure it for ST7789:
2. Copy the `User_Setup.h` file from this project to your TFT_eSPI library folder
3. The library folder is typically located at:
   - Windows: `Documents/Arduino/libraries/TFT_eSPI/`
   - Mac: `~/Documents/Arduino/libraries/TFT_eSPI/`
   - Linux: `~/Arduino/libraries/TFT_eSPI/`

## Setup Instructions

### 1. ESP32 Setup

1. Open `esp32_navigation_display.ino` in Arduino IDE
2. Update WiFi credentials:
   ```cpp
   const char* ssid = "YOUR_WIFI_SSID";
   const char* password = "YOUR_WIFI_PASSWORD";
   ```
3. Select the correct board: Tools > Board > ESP32 Dev Module
4. Select the correct port: Tools > Port > (your ESP32 port)
5. Upload the code to ESP32

### 2. Flutter App Setup

1. The Flutter app's `HelmetService` has been updated to send navigation data via WebSocket
2. After uploading the ESP32 code, note the IP address displayed on the LCD
3. In the Flutter app, you can set the ESP32 IP address by calling:
   ```dart
   HelmetService().setESP32IpAddress('192.168.1.XXX');
   ```

### 3. Testing the Connection

1. Power on the ESP32 - it should display "Ready" and show its IP address
2. Run the Flutter app and start navigation
3. The ESP32 display should show:
   - Current navigation instruction
   - Distance to next turn
   - Total distance
   - Estimated time of arrival
   - Connection status

## Display Features

The ST7789 display shows:

- **Header**: "NAVIGATION" with status indicator
- **Main Instruction**: Current turn-by-turn direction (with word wrapping)
- **Distance Info**: Distance to next turn (in meters or kilometers)
- **Trip Info**: Total distance and estimated time
- **Progress Bar**: Visual progress indicator
- **Connection Status**: ESP32 IP address and connection status

## Troubleshooting

### Display Issues
- Check wiring connections
- Verify TFT_eSPI configuration in `User_Setup.h`
- Ensure correct pin assignments

### WiFi Connection Issues
- Verify WiFi credentials
- Check if ESP32 and phone are on the same network
- Monitor Serial output for connection status

### Communication Issues
- Ensure both devices are on the same WiFi network
- Check the IP address displayed on the ESP32
- Verify WebSocket connection in Flutter app logs

### Common Problems

1. **Display shows nothing**: Check power and wiring
2. **Display shows garbled text**: Verify TFT_eSPI configuration
3. **No navigation data**: Check WiFi connection and IP address
4. **Flutter app can't connect**: Ensure ESP32 WebSocket server is running

## Customization

You can customize the display by modifying:

- Colors: Change the color definitions at the top of the Arduino code
- Layout: Modify the `updateDisplay()` function
- Update frequency: Change the WebSocket polling interval
- Display rotation: Modify `tft.setRotation()` value

## Future Enhancements

- Add turn arrow indicators
- Implement voice commands
- Add speed display from helmet sensors
- Include weather information
- Add emergency contact features