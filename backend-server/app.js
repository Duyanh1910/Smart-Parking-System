// app.js
const express = require('express');
const cors = require('cors');
const http = require('http');
const { initWebSocket } = require('./websocket');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const api = require('./routes/api');
app.use('/api', api);

app.get('/', (req, res) => res.send('Hello 🚀'));

const server = http.createServer(app);
initWebSocket(server);

const PORT = 3000;
server.listen(PORT, () => console.log(`🚀 Server chạy tại http://localhost:${PORT}`));


