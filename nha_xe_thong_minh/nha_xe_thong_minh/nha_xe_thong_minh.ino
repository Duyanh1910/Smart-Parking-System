#include <Arduino.h>      
#include <WiFiClientSecure.h>
#include <WiFi.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <PubSubClient.h>
#include "config.h"

// ---------------- MQTT + LCD + WiFi ----------------
WiFiClientSecure espClient;
PubSubClient client(espClient);
LiquidCrystal_I2C lcd(0x27, 16, 2);

String currentDoorState = "DUNG";
String currentPlate = "--------                    ";

// ---------------- WIFI ----------------
void wifiConnection() {
  Serial.print("Connecting WiFi: ");
  Serial.println(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  unsigned long t = millis();
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    if (millis() - t > 10000) {
      Serial.println("❌ WiFi failed!");
      return;
    }
  }
  Serial.println("\n✅ WiFi connected!");
  Serial.print("IP: ");
  Serial.println(WiFi.localIP());
}

// ---------------- MOTOR ----------------
int motor1Pin1 = 27;int motor1Pin2 = 26;int enable1Pin = 14;

int pwmChannel = 0;
const int freq = 20000;
const int resolution = 8;

// Công tắc hành trình
int limitOpenPin = 32;
int limitClosePin = 33;

bool doorMoving = false;
bool doorJustOpened = false;
unsigned long doorStopTime = 0;

// ---------------- LCD ----------------
void capNhatLCD() {
  lcd.setCursor(0, 0);
  lcd.print("BSX: " + currentPlate + " ");
  lcd.setCursor(0, 1);
  lcd.print("Trang thai: " + currentDoorState + "   ");
}

// ---------------- MQTT CALLBACK ----------------
void moCua();
void dongCua();
void dungCua();

void callback(char* topic, byte* payload, unsigned int length) {
  String msg = "";
  for (int i = 0; i < length; i++) msg += (char)payload[i];

  Serial.println("Message: [" + String(topic) + "] " + msg);

  if (String(topic) == "door/control") {
    
    if (msg.startsWith("OPEN")) {
      moCua();
      client.publish("door/state", "MO", true);

      // Lấy biển số nếu có
      int colonIndex = msg.indexOf(":");
      if (colonIndex != -1) {
        currentPlate = msg.substring(colonIndex + 1);
      } else {
        currentPlate = "N/A";
      }
      capNhatLCD();
    }
    else if (msg == "CLOSE") {
      dongCua();
      client.publish("door/state", "DONG", true);
      currentPlate = "--------                    "; // xóa biển số
      capNhatLCD();
    }
    else if (msg == "STOP") {
      dungCua();
      client.publish("door/state", "DUNG", true);
    }
  }
}

// ---------------- MQTT RECONNECT ----------------
const char* statusTopic = "door/status";
const char* clientID = "ESP32-Door1";

void reconnect() {
  while (!client.connected()) {
    Serial.print("MQTT connecting...");
    if (client.connect(clientID, MQTT_USERNAME, MQTT_PASSWORD, statusTopic, 1, true, "OFFLINE")) {

      Serial.println("OK!");
      client.subscribe("door/control");

      client.publish(statusTopic, "ONLINE", true);
      client.publish("door/state", currentDoorState.c_str(), true);

    } else {
      Serial.print("Failed, rc=");
      Serial.println(client.state());
      delay(5000);
    }
  }
}

// ----------------= ĐIỀU KHIỂN CỬA ----------------
void moCua() {
  if (doorMoving || currentDoorState == "MO") return;

  doorMoving = true;
  digitalWrite(motor1Pin1, HIGH);
  digitalWrite(motor1Pin2, LOW);
  ledcWrite(pwmChannel, 210);

  currentDoorState = "MO";
  Serial.println("Cua dang mo");
  capNhatLCD();
}

void dongCua() {
  if (doorMoving || currentDoorState == "DONG") return;

  doorMoving = true;
  digitalWrite(motor1Pin1, LOW);
  digitalWrite(motor1Pin2, HIGH);
  ledcWrite(pwmChannel, 200);

  currentDoorState = "DONG";
  Serial.println("Cua dang dong");
  capNhatLCD();
}

void dungCua() {
  if (currentDoorState == "DUNG") return;

  digitalWrite(motor1Pin1, LOW);
  digitalWrite(motor1Pin2, LOW);
  ledcWrite(pwmChannel, 0);

  currentDoorState = "DUNG";
  doorMoving = false;

  Serial.println("Cua dung");
  capNhatLCD();
}

// ---------------- SETUP ----------------
bool lastOpenState = HIGH;
bool lastCloseState = HIGH;

void setup() {
  Serial.begin(115200);

  lcd.init();
  lcd.backlight();
  capNhatLCD();

  ledcSetup(pwmChannel, freq, resolution);
  ledcAttachPin(enable1Pin, pwmChannel);

  pinMode(motor1Pin1, OUTPUT);
  pinMode(motor1Pin2, OUTPUT);
  pinMode(limitOpenPin, INPUT_PULLUP);
  pinMode(limitClosePin, INPUT_PULLUP);

  wifiConnection();

  espClient.setInsecure();  

  client.setServer(MQTT_BROKER, MQTT_PORT);
  client.setCallback(callback);
}

// ---------------- LOOP ----------------
void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  bool curOpen = digitalRead(limitOpenPin);
  bool curClose = digitalRead(limitClosePin);

  // Khi mở chạm công tắc giới hạn
  if (currentDoorState == "MO" && curOpen == LOW && lastOpenState == HIGH) {
    dungCua();
    doorStopTime = millis();
    doorJustOpened = true;
    client.publish("door/state", currentDoorState.c_str(), true);
  }

  // Khi đóng chạm công tắc giới hạn
  if (currentDoorState == "DONG" && curClose == LOW && lastCloseState == HIGH) {
    dungCua();
    doorJustOpened = false;
    client.publish("door/state", currentDoorState.c_str(), true);
  }

  // Tự động đóng sau 5s
  if (doorJustOpened && millis() - doorStopTime >= 5000) {
    doorJustOpened = false;
    dongCua();
    client.publish("door/state", currentDoorState.c_str(), true);
    currentPlate = "--------                    ";// reset biển số
    capNhatLCD();
  }

  lastOpenState = curOpen;
  lastCloseState = curClose;
}
