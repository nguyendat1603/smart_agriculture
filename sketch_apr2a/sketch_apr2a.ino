#include <WiFi.h>
#include <FirebaseESP32.h>
#include "DHT.h"

// --- 1. THÔNG TIN KẾT NỐI ---
#define WIFI_SSID "PP"
#define WIFI_PASSWORD "password"
#define FIREBASE_HOST "project1-bacb2-default-rtdb.asia-southeast1.firebasedatabase.app" 
#define FIREBASE_AUTH "UB3BdYevfZyBopccijM2qVJHLhJlS98uW7F9ZkFG"

// --- 2. CẤU HÌNH CHÂN CẮM ---
#define DHTPIN 4       // Chân DATA của DHT22 nối vào D4
#define DHTTYPE DHT22  
#define SOIL_PIN 34    // Chân AO của cảm biến đất nối vào D34
#define RAIN_PIN 35    // Chân AO của cảm biến MƯA nối vào D35
#define PUMP_LED_PIN 2 // Chân LED máy bơm (mô phỏng) là chân số 2

DHT dht(DHTPIN, DHTTYPE);
FirebaseData fbdo;
FirebaseConfig config;
FirebaseAuth auth;

unsigned long lastLogTime = 0;
unsigned long lastPumpCheckTime = 0; 
const long pumpCheckInterval = 1000; // Kiểm tra lệnh bơm từ App (1 giây / lần)
const long logInterval = 10000;      // Đẩy dữ liệu cảm biến lên App (10 giây / lần)

void setup() {
  Serial.begin(115200);
  dht.begin();

  // Kết nối WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Dang ket noi WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nDa ket noi WiFi!");

  // Cấu hình Firebase
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Cài đặt chân điều khiển LED bơm
  pinMode(PUMP_LED_PIN, OUTPUT);
  digitalWrite(PUMP_LED_PIN, LOW);
}

void loop() {
  unsigned long currentMillis = millis();

  // ---------------------------------------------------------
  // LUỒNG 1: LẮNG NGHE LỆNH ĐIỀU KHIỂN BƠM (1 GIÂY / LẦN)
  // ---------------------------------------------------------
  if (currentMillis - lastPumpCheckTime >= pumpCheckInterval) {
    lastPumpCheckTime = currentMillis;

    if (Firebase.getBool(fbdo, "/NongNghiep/TrangThaiBom")) {
      bool isPumpOn = fbdo.boolData();
      if (isPumpOn) {
        digitalWrite(PUMP_LED_PIN, HIGH);
        Serial.println(">> APP RA LENH: BAT MAY BOM (LED SANG)");
      } else {
        digitalWrite(PUMP_LED_PIN, LOW);
        Serial.println(">> APP RA LENH: TAT MAY BOM (LED TOI)");
      }
    }
  }

  // ---------------------------------------------------------
  // LUỒNG 2: CẬP NHẬT DỮ LIỆU CẢM BIẾN REALTIME (10 GIÂY / LẦN)
  // ---------------------------------------------------------
  if (currentMillis - lastLogTime >= logInterval) {
    lastLogTime = currentMillis;

    // Đọc cảm biến nhiệt độ & độ ẩm không khí DHT22
    float h_air = dht.readHumidity();
    float t_air = dht.readTemperature();

    // Đọc cảm biến độ ẩm đất (D34)
    int soilRaw = analogRead(SOIL_PIN);
    int soilPercent = map(soilRaw, 4095, 1800, 0, 100);
    if(soilPercent > 100) soilPercent = 100;
    if(soilPercent < 0) soilPercent = 0;

    // Đọc cảm biến nước mưa (D35)
    int rainRaw = analogRead(RAIN_PIN);
    int rainPercent = map(rainRaw, 4095, 1500, 0, 100);
    if(rainPercent > 100) rainPercent = 100;
    if(rainPercent < 0) rainPercent = 0;

    // Mực nước bồn chứa giả định cố định 100%
    int waterPercent = 100; 

    // Kiểm tra cảm biến DHT22 hoạt động bình thường thì mới đẩy dữ liệu
    if (!isnan(h_air) && !isnan(t_air)) {
      
      // ĐẨY DỮ LIỆU THỜI GIAN THỰC LÊN NHÁNH CHÍNH
      Firebase.setFloat(fbdo, "/NongNghiep/NhietDo", t_air);
      Firebase.setFloat(fbdo, "/NongNghiep/DoAmKhongKhi", h_air);
      Firebase.setInt(fbdo, "/NongNghiep/DoAmDat", soilPercent);
      Firebase.setInt(fbdo, "/NongNghiep/DoAm", rainPercent);     
      Firebase.setInt(fbdo, "/NongNghiep/MucNuoc", waterPercent); 

      Serial.println(">> Da dong bo du lieu Realtime len Firebase.");
    }
  }
}