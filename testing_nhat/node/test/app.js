// =========================
// CẤU HÌNH MQTT HIVE MQ CLOUD
// =========================
const mqtt = require("mqtt");
const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

// Thông tin MQTT của bạn
const MQTT_BROKER = "mqtts://edbbea48be36467bb4baeea211156ed0.s1.eu.hivemq.cloud";
const MQTT_USERNAME = "nha_xe_thong_minh";
const MQTT_PASSWORD = "Nhaxe123";
const MQTT_PORT = 8883;

// 🚨 Topic ESP32 đang subscribe
const TOPIC_DOOR = "door/control";  // ĐÃ SỬA LẠI CHUẨN

// Kết nối tới MQTT
const client = mqtt.connect(MQTT_BROKER, {
  port: MQTT_PORT,
  username: MQTT_USERNAME,
  password: MQTT_PASSWORD,
  protocol: "mqtts",
});

// Xử lý event khi kết nối thành công
client.on("connect", () => {
  console.log("✅ Node.js đã kết nối MQTT HiveMQ Cloud");
});

// =========================
// API ĐIỀU KHIỂN CỬA
// =========================

// Mở cửa
app.get("/door/open", (req, res) => {
  client.publish(TOPIC_DOOR, "OPEN");
  res.json({ status: "OK", message: "Đã gửi tín hiệu mở cửa" });
});

// Đóng cửa
app.get("/door/close", (req, res) => {
  client.publish(TOPIC_DOOR, "CLOSE");
  res.json({ status: "OK", message: "Đã gửi tín hiệu đóng cửa" });
});

// Dừng cửa (nếu bạn muốn)
app.get("/door/stop", (req, res) => {
  client.publish(TOPIC_DOOR, "STOP");
  res.json({ status: "OK", message: "Đã gửi tín hiệu dừng cửa" });
});

// Kiểm tra server hoạt động
app.get("/", (req, res) => {
  res.send("Server Node.js điều khiển cửa đang chạy...");
});

// =========================
// KHỞI ĐỘNG SERVER
// =========================
app.listen(3000, () => {
  console.log("🚀 Server Node.js chạy tại http://localhost:3000/");
});
