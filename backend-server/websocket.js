const WebSocket = require('ws');
const dayjs = require('dayjs');
const utc = require('dayjs/plugin/utc');
const timezone = require('dayjs/plugin/timezone');
const db = require('./config/db');  
const mqttClient = require('./config/mqttClient');

dayjs.extend(utc);
dayjs.extend(timezone);

let wss;

function heartbeat() {
  this.isAlive = true;
}

function initWebSocket(server) {
  wss = new WebSocket.Server({ server });
  wss.broadcast = (data) => {
    const message = JSON.stringify(data); 
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  };
    mqttClient.on('message', (topic, message) => {
    const payload = message.toString();
    console.log(`📥 MQTT: ${topic} | ${payload}`);

    if (topic === 'door/state') {
      wss.broadcast({
        type: 'door_state',
        state: payload
      });
    }

    if (topic === 'door/status') {
      wss.broadcast({
        type: 'door_status',
        status: payload
      });
    }
  });
  wss.on('connection', (ws) => {
    console.log('✅ Client connected');

    ws.isAlive = true;
    ws.on('pong', heartbeat); 

    ws.send(JSON.stringify({
      type: "status",
      online: true
    }));
    ws.on('message', async (msg) => {
      let data;

      try {
        data = JSON.parse(msg.toString());
      } catch (e) {
        console.log("❌ JSON không hợp lệ:", msg.toString());
        return;
      }

      console.log('📩 Received:', data);
      if (data.type === "ping") {
        ws.send(JSON.stringify({ type: "pong" }));
        return;
      }

      if (data.type !== "cmd") return;

      if (data.action === "open") {
        console.log("🥏 Lệnh: MỞ CỬA");
        try {
          if (mqttClient.connected) {
              mqttClient.publish("door/control", "OPEN");
          } else {
            console.log("❌ MQTT chưa kết nối");
          }
        } catch (err) {
          console.error(err);
        }
      }

      if (data.action === "open_nodatabase") {
        const plate = data.plate;
        if (!plate) {
          console.log("❌ Không nhận được plate từ client");
          return;
        }
        console.log("🥏 Lệnh: MỞ CỬA KO LƯU CSDL");
        try {
          const sql2 = "INSERT INTO parking_id(plate_id,checkIn_time) VALUES(?,?)";
          const now = dayjs().tz('Asia/Ho_Chi_Minh').format('YYYY-MM-DD HH:mm:ss');
          await db.execute(sql2, [plate, now]);
          if (mqttClient.connected) {
            mqttClient.publish("door/control", `OPEN:${plate}`);
          } else {
            console.log("❌ MQTT chưa kết nối");
          }
        } catch (err) {
          console.error("❌ Lỗi khi lưu DB:", err);
        }
      }

      if (data.action === "open_database") {
        console.log("🥏 Lệnh: MỞ CỬA VÀ LƯU CSDL");

        const plate = data.plate;
        if (!plate) {
          console.log("❌ Không nhận được plate từ client");
          return;
        }

        try {
          const sql1 = "INSERT INTO vehicle(plate_id) VALUES(?)";
          await db.execute(sql1, [plate]);

          const sql2 = "INSERT INTO parking_id(plate_id,checkIn_time) VALUES(?,?)";
          const now = dayjs().tz('Asia/Ho_Chi_Minh').format('YYYY-MM-DD HH:mm:ss');
          await db.execute(sql2, [plate, now]);
          if (mqttClient.connected) {
            mqttClient.publish("door/control", `OPEN:${plate}`);
          } else {
            console.log("❌ MQTT chưa kết nối");
          }
          console.log(`✅ Biển số xe ${plate} đã được lưu`);

        } catch (err) {
          console.error("❌ Lỗi khi lưu DB:", err);
        }
      }

      if (data.action === "close") {
        console.log("🥏 Lệnh: ĐÓNG CỬA");
        if (mqttClient.connected) {
          mqttClient.publish("door/control", "CLOSE");
        } else {
          console.log("❌ MQTT chưa kết nối");
        }
      }

      if (data.action === "stop") {
        console.log("🥏 Lệnh: DỪNG CỬA");
        if (mqttClient.connected) {
          mqttClient.publish("door/control", "STOP");
        } else {
          console.log("❌ MQTT chưa kết nối");
        }
      }
    });
    ws.on("close", () => {
      console.log("❌ Client disconnected");
    });

    ws.on("error", (err) => {
      console.log("⚠️ WS error:", err.message);
    });
  });
  const interval = setInterval(() => {
    wss.clients.forEach((ws) => {
      if (ws.isAlive === false) {
        console.log("💀 Terminate dead client");
        return ws.terminate();
      }

      ws.isAlive = false;
      ws.ping();
    });
  }, 30000);

  wss.on("close", () => {
    clearInterval(interval);
  });

  return wss;
}

function getWss() {
  if (!wss) throw new Error("WebSocket chưa được khởi tạo");
  return wss;
}

module.exports = { initWebSocket, getWss };

