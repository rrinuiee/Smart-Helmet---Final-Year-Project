#include <WiFi.h>
#include <WebSocketsServer.h>
#include <ArduinoJson.h>
#include <TFT_eSPI.h>
#include <SPI.h>

// TFT Display setup for ST7789
TFT_eSPI tft = TFT_eSPI();

// WebSocket server on port 81
WebSocketsServer webSocket = WebSocketsServer(81);

// WiFi credentials - update these
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// Connection management
bool wifiConnected = false;
bool clientConnected = false;
unsigned long lastHeartbeat = 0;
unsigned long lastDataUpdate = 0;
const unsigned long HEARTBEAT_INTERVAL = 30000; // 30 seconds
const unsigned long DATA_TIMEOUT = 60000; // 1 minute

// Navigation data structure
struct NavigationData {
  String currentInstruction;
  float distanceToNextTurn;
  float totalDistance;
  int estimatedTimeMinutes;
  String status;
  bool isNavigating;
  unsigned long lastUpdate;
};

NavigationData navData;

// Display colors
#define BG_COLOR TFT_BLACK
#define TEXT_COLOR TFT_WHITE
#define INSTRUCTION_COLOR TFT_CYAN
#define DISTANCE_COLOR TFT_YELLOW
#define STATUS_COLOR TFT_GREEN
#define WARNING_COLOR TFT_RED
#define INFO_COLOR TFT_BLUE

void setup() {
  Serial.begin(115200);
  Serial.println("Smart Helmet Navigation Display Starting...");
  
  // Initialize display
  tft.init();
  tft.setRotation(1); // Landscape mode
  tft.fillScreen(BG_COLOR);
  tft.setTextColor(TEXT_COLOR, BG_COLOR);
  
  // Show startup screen
  showStartupScreen();
  
  // Initialize navigation data
  initializeNavigationData();
  
  // Connect to WiFi
  connectToWiFi();
  
  // Initialize WebSocket server if WiFi connected
  if (wifiConnected) {
    webSocket.begin();
    webSocket.onEvent(webSocketEvent);
    showReadyScreen();
    Serial.println("WebSocket server started on port 81");
  } else {
    showErrorScreen("WiFi Connection Failed");
  }
}

void loop() {
  if (wifiConnected) {
    webSocket.loop();
    
    // Check for data timeout
    if (clientConnected && navData.isNavigating) {
      if (millis() - lastDataUpdate > DATA_TIMEOUT) {
        Serial.println("Navigation data timeout - stopping navigation");
        navData.isNavigating = false;
        navData.status = "timeout";
        updateDisplay();
      }
    }
    
    // Send heartbeat
    if (millis() - lastHeartbeat > HEARTBEAT_INTERVAL) {
      sendHeartbeat();
      lastHeartbeat = millis();
    }
  } else {
    // Try to reconnect WiFi
    if (millis() % 30000 == 0) { // Every 30 seconds
      connectToWiFi();
    }
  }
  
  delay(100);
}

void connectToWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(ssid);
  
  WiFi.begin(ssid, password);
  updateConnectionStatus("Connecting to WiFi...");
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    wifiConnected = true;
    Serial.println();
    Serial.print("Connected! IP address: ");
    Serial.println(WiFi.localIP());
  } else {
    wifiConnected = false;
    Serial.println();
    Serial.println("WiFi connection failed!");
  }
}

void initializeNavigationData() {
  navData.currentInstruction = "Waiting for navigation...";
  navData.distanceToNextTurn = 0;
  navData.totalDistance = 0;
  navData.estimatedTimeMinutes = 0;
  navData.status = "idle";
  navData.isNavigating = false;
  navData.lastUpdate = millis();
}

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_DISCONNECTED:
      Serial.printf("[%u] Disconnected!\n", num);
      clientConnected = false;
      showConnectionStatus("App Disconnected");
      break;
      
    case WStype_CONNECTED: {
      IPAddress ip = webSocket.remoteIP(num);
      Serial.printf("[%u] Connected from %d.%d.%d.%d\n", num, ip[0], ip[1], ip[2], ip[3]);
      clientConnected = true;
      showConnectionStatus("App Connected");
      
      // Send welcome message
      String welcomeMsg = "{\"type\":\"welcome\",\"message\":\"ESP32 Display Ready\"}";
      webSocket.sendTXT(num, welcomeMsg);
      break;
    }
    
    case WStype_TEXT:
      Serial.printf("[%u] Received: %s\n", num, payload);
      if (parseNavigationData((char*)payload)) {
        lastDataUpdate = millis();
        updateDisplay();
        
        // Send acknowledgment
        String ackMsg = "{\"type\":\"ack\",\"status\":\"received\"}";
        webSocket.sendTXT(num, ackMsg);
      }
      break;
      
    case WStype_ERROR:
      Serial.printf("[%u] Error: %s\n", num, payload);
      break;
      
    default:
      break;
  }
}

bool parseNavigationData(const char* jsonString) {
  DynamicJsonDocument doc(1024);
  DeserializationError error = deserializeJson(doc, jsonString);
  
  if (error) {
    Serial.print("JSON parsing failed: ");
    Serial.println(error.c_str());
    return false;
  }
  
  // Check if this is a heartbeat or other message type
  if (doc.containsKey("type")) {
    String msgType = doc["type"].as<String>();
    if (msgType == "heartbeat") {
      Serial.println("Heartbeat received from app");
      return false; // Don't update display for heartbeat
    }
  }
  
  // Parse navigation data
  if (doc.containsKey("instruction")) {
    navData.currentInstruction = doc["instruction"].as<String>();
    navData.distanceToNextTurn = doc["distanceToNextTurn"].as<float>();
    navData.totalDistance = doc["totalDistance"].as<float>();
    navData.estimatedTimeMinutes = doc["estimatedTimeMinutes"].as<int>();
    navData.status = doc["status"].as<String>();
    navData.isNavigating = doc["isNavigating"].as<bool>();
    navData.lastUpdate = millis();
    
    Serial.println("Navigation data updated:");
    Serial.println("Instruction: " + navData.currentInstruction);
    Serial.println("Distance to turn: " + String(navData.distanceToNextTurn) + " km");
    Serial.println("Status: " + navData.status);
    return true;
  }
  
  return false;
}

void sendHeartbeat() {
  if (clientConnected) {
    String heartbeat = "{\"type\":\"heartbeat\",\"timestamp\":" + String(millis()) + "}";
    webSocket.broadcastTXT(heartbeat);
  }
}

void showStartupScreen() {
  tft.fillScreen(BG_COLOR);
  tft.setTextSize(2);
  tft.setTextColor(STATUS_COLOR);
  tft.drawCentreString("Smart Helmet", 120, 40, 2);
  tft.drawCentreString("Navigation Display", 120, 70, 2);
  
  tft.setTextSize(1);
  tft.setTextColor(TEXT_COLOR);
  tft.drawCentreString("Initializing...", 120, 120, 2);
}

void showReadyScreen() {
  tft.fillScreen(BG_COLOR);
  tft.setTextSize(2);
  tft.setTextColor(STATUS_COLOR);
  tft.drawCentreString("Ready", 120, 40, 2);
  
  tft.setTextSize(1);
  tft.setTextColor(TEXT_COLOR);
  tft.drawCentreString("IP: " + WiFi.localIP().toString(), 120, 80, 2);
  tft.drawCentreString("Waiting for app connection...", 120, 110, 2);
  
  // Show QR code placeholder (you could generate actual QR code)
  tft.drawRect(85, 140, 70, 70, TEXT_COLOR);
  tft.setTextColor(TFT_DARKGREY);
  tft.drawCentreString("QR Code", 120, 170, 1);
  tft.drawCentreString("(Connect App)", 120, 185, 1);
}

void showErrorScreen(String error) {
  tft.fillScreen(BG_COLOR);
  tft.setTextSize(2);
  tft.setTextColor(WARNING_COLOR);
  tft.drawCentreString("Error", 120, 40, 2);
  
  tft.setTextSize(1);
  tft.setTextColor(TEXT_COLOR);
  tft.drawCentreString(error, 120, 80, 2);
  tft.drawCentreString("Check settings and restart", 120, 110, 2);
}

void showConnectionStatus(String status) {
  tft.fillRect(0, 200, 240, 40, BG_COLOR);
  tft.setTextSize(1);
  tft.setTextColor(TEXT_COLOR);
  tft.drawCentreString(status, 120, 210, 2);
}

void updateConnectionStatus(String status) {
  tft.fillRect(0, 120, 240, 30, BG_COLOR);
  tft.setTextSize(1);
  tft.setTextColor(TEXT_COLOR);
  tft.drawCentreString(status, 120, 125, 2);
}

void updateDisplay() {
  tft.fillScreen(BG_COLOR);
  
  // Header with connection status
  tft.setTextSize(1);
  tft.setTextColor(STATUS_COLOR);
  tft.drawCentreString("SMART HELMET NAVIGATION", 120, 5, 2);
  
  // Connection indicators
  uint16_t wifiColor = wifiConnected ? STATUS_COLOR : WARNING_COLOR;
  uint16_t appColor = clientConnected ? STATUS_COLOR : WARNING_COLOR;
  
  tft.fillCircle(200, 15, 3, wifiColor);  // WiFi indicator
  tft.fillCircle(210, 15, 3, appColor);   // App connection indicator
  
  // Status indicator for navigation
  uint16_t statusColor = STATUS_COLOR;
  if (navData.status == "error" || navData.status == "timeout") statusColor = WARNING_COLOR;
  else if (navData.status == "calculating") statusColor = TFT_ORANGE;
  else if (navData.status == "arrived") statusColor = INFO_COLOR;
  
  tft.fillCircle(220, 15, 3, statusColor);
  
  if (!clientConnected) {
    // Show connection screen
    tft.setTextSize(1);
    tft.setTextColor(TEXT_COLOR);
    tft.drawCentreString("Waiting for app...", 120, 50, 2);
    tft.drawCentreString("IP: " + WiFi.localIP().toString(), 120, 80, 2);
    return;
  }
  
  // Current instruction (main display)
  tft.setTextSize(1);
  tft.setTextColor(INSTRUCTION_COLOR);
  
  // Word wrap for long instructions
  String instruction = navData.currentInstruction;
  if (instruction.length() > 25) {
    int spaceIndex = instruction.indexOf(' ', 20);
    if (spaceIndex > 0 && spaceIndex < instruction.length() - 5) {
      String line1 = instruction.substring(0, spaceIndex);
      String line2 = instruction.substring(spaceIndex + 1);
      
      tft.drawCentreString(line1, 120, 35, 2);
      if (line2.length() > 25) {
        int spaceIndex2 = line2.indexOf(' ', 20);
        if (spaceIndex2 > 0) {
          String line2a = line2.substring(0, spaceIndex2);
          String line2b = line2.substring(spaceIndex2 + 1);
          tft.drawCentreString(line2a, 120, 55, 2);
          tft.drawCentreString(line2b, 120, 75, 1);
        } else {
          tft.drawCentreString(line2, 120, 55, 2);
        }
      } else {
        tft.drawCentreString(line2, 120, 55, 2);
      }
    } else {
      tft.drawCentreString(instruction, 120, 45, 2);
    }
  } else {
    tft.drawCentreString(instruction, 120, 45, 2);
  }
  
  if (navData.isNavigating) {
    // Distance to next turn
    tft.setTextColor(DISTANCE_COLOR);
    if (navData.distanceToNextTurn > 0) {
      String distanceText;
      if (navData.distanceToNextTurn < 1.0) {
        distanceText = String((int)(navData.distanceToNextTurn * 1000)) + " m";
      } else {
        distanceText = String(navData.distanceToNextTurn, 1) + " km";
      }
      tft.setTextSize(2);
      tft.drawCentreString(distanceText, 120, 95, 2);
      
      tft.setTextSize(1);
      tft.setTextColor(TFT_DARKGREY);
      tft.drawCentreString("to next turn", 120, 115, 1);
    }
    
    // Total distance and ETA
    tft.setTextColor(TEXT_COLOR);
    tft.setTextSize(1);
    
    String totalDist = String(navData.totalDistance, 1) + " km total";
    tft.drawCentreString(totalDist, 120, 140, 1);
    
    if (navData.estimatedTimeMinutes > 0) {
      String eta;
      if (navData.estimatedTimeMinutes >= 60) {
        int hours = navData.estimatedTimeMinutes / 60;
        int minutes = navData.estimatedTimeMinutes % 60;
        eta = String(hours) + "h " + String(minutes) + "m";
      } else {
        eta = String(navData.estimatedTimeMinutes) + " min";
      }
      tft.drawCentreString("ETA: " + eta, 120, 155, 1);
    }
    
    // Progress bar
    drawProgressBar();
  } else {
    // Show status message
    tft.setTextColor(TEXT_COLOR);
    tft.setTextSize(1);
    if (navData.status == "arrived") {
      tft.setTextColor(INFO_COLOR);
      tft.drawCentreString("Destination Reached!", 120, 100, 2);
    } else if (navData.status == "timeout") {
      tft.setTextColor(WARNING_COLOR);
      tft.drawCentreString("Connection Lost", 120, 100, 2);
    } else {
      tft.drawCentreString("Ready for navigation", 120, 100, 2);
    }
  }
  
  // Footer with IP and timestamp
  tft.setTextColor(TFT_DARKGREY);
  tft.setTextSize(1);
  tft.drawCentreString("IP: " + WiFi.localIP().toString(), 120, 210, 1);
  
  // Data age indicator
  unsigned long dataAge = millis() - navData.lastUpdate;
  if (dataAge > 10000) { // More than 10 seconds old
    String ageText = "Data: " + String(dataAge / 1000) + "s ago";
    tft.drawCentreString(ageText, 120, 225, 1);
  }
}

void drawProgressBar() {
  // Simple progress visualization
  int barWidth = 200;
  int barHeight = 8;
  int barX = 20;
  int barY = 180;
  
  // Background
  tft.fillRect(barX, barY, barWidth, barHeight, TFT_DARKGREY);
  
  // Progress (simplified - you could calculate actual progress)
  if (navData.distanceToNextTurn > 0 && navData.totalDistance > 0) {
    float progress = 1.0 - (navData.distanceToNextTurn / navData.totalDistance);
    int progressWidth = (int)(barWidth * progress);
    tft.fillRect(barX, barY, progressWidth, barHeight, STATUS_COLOR);
  }
}