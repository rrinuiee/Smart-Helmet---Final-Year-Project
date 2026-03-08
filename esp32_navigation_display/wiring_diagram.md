# ESP32 to ST7789 Wiring Diagram

```
ESP32 Dev Kit V1          ST7789 240x240 LCD
┌─────────────────┐      ┌─────────────────┐
│                 │      │                 │
│             3.3V├──────┤VCC              │
│              GND├──────┤GND              │
│         GPIO 18 ├──────┤SCL (Clock)      │
│         GPIO 23 ├──────┤SDA (MOSI)       │
│          GPIO 4 ├──────┤RES (Reset)      │
│          GPIO 2 ├──────┤DC (Data/Cmd)    │
│         GPIO 22 ├──────┤BLK (Backlight) │
│                 │      │                 │
└─────────────────┘      └─────────────────┘
```

## Pin Connections:

| ESP32 Pin | ST7789 Pin | Function |
|-----------|------------|----------|
| 3.3V      | VCC        | Power Supply (3.3V) |
| GND       | GND        | Ground |
| GPIO 18   | SCL        | SPI Clock |
| GPIO 23   | SDA/MOSI   | SPI Data |
| GPIO 4    | RES        | Reset |
| GPIO 2    | DC         | Data/Command |
| GPIO 22   | BLK        | Backlight Control |

## Notes:
- Use 3.3V power supply (NOT 5V)
- Some ST7789 modules don't have a CS (Chip Select) pin
- Backlight (BLK) connection is optional but recommended
- Double-check your specific ST7789 module pinout as they may vary