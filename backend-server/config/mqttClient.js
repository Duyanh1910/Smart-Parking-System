const mqtt = require('mqtt');
const {
  MQTT_USERNAME,
  MQTT_PASSWORD,
  MQTT_BROKER,
  MQTT_PORT
} = require('./constants');

const client = mqtt.connect(MQTT_BROKER, {
  username: MQTT_USERNAME,
  password: MQTT_PASSWORD,
  protocol: "mqtts",
  port: MQTT_PORT,
  rejectUnauthorized: false,
  clean: true,
  reconnectPeriod: 3000,
  connectTimeout: 5000
});

client.on('connect', () => {
  console.log('✅ MQTT connected');

  client.subscribe('door/state', { qos: 1 });
  client.subscribe('door/status', { qos: 1 });
});

client.on('reconnect', () => {
  console.log('🔄 MQTT reconnecting...');
});

client.on('error', (err) => {
  console.error('❌ MQTT error:', err.message);
});

module.exports = client;
