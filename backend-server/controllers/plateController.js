const express = require("express");
const router = express.Router();
const db = require('../config/db');
const axios = require("axios");
const dayjs = require('dayjs');
const utc = require('dayjs/plugin/utc');
const timezone = require('dayjs/plugin/timezone');
const admin = require("../config/firebase");
const { getWss } = require('../websocket');
const mqttClient = require('../config/mqttClient');
dayjs.extend(utc);
dayjs.extend(timezone);

const { FCM_TOKEN } = require('../config/constants');

exports.plate = async(req,res) =>{
    try{
        const plate = req.body.plate;
        console.log(`Biển số xe: ${plate}`);
        if(!plate){
            return res.json({
                status: "ERROR",
                message: "Missing plate"
            });
        }
        const sql = "SELECT * FROM vehicle WHERE plate_id = ?"; 
        const [results] = await db.query(sql,[plate]); 
        if(results.length>0){
            console.log("✅ Xe hợp lệ:", plate);
            const sql2 = "INSERT INTO parking_id(plate_id,checkIn_time) VALUES(?,?)";
            const now = dayjs().tz('Asia/Ho_Chi_Minh').format('YYYY-MM-DD HH:mm:ss');
            const results2 = await db.execute(sql2,[plate,now]);
            mqttClient.publish("door/control", `OPEN:${plate}`);
            const wss = getWss(); 
            wss.broadcast({
                type: "PLATE",
                plate,
                message: "Biển số xe hợp lệ",
            });
            return res.json(
                {
                    status: "ALLOWED",
                    message: "Biển số xe hợp lệ",
                    plate
                }
            );
        }
        else{
            console.log("❌ Xe không hợp lệ:", plate);
            const message = {
                token: FCM_TOKEN,
                android: {
                    priority: "high",
                },
                data: {
                    title: "🚗 Phát hiện biển số mới!",
                    body: `Biển số xe: ${plate}`,
                    plate: plate,
                    type: "NEW_PLATE",
                },
            };
            await admin.messaging().send(message);
            const sql3 = "INSERT INTO notification(title) VALUES(?)"; 
            const results3 = await db.query(sql3,[plate]); 
            const wss = getWss(); 
            wss.broadcast({
                type: "NEW_PLATE",
                plate,
                message: "Phát hiện xe mới, yêu cầu xác nhận mở cửa!!"
            });
            return res.json(
                {
                    status: "NOT_ALLOWED",
                    message: "Biển số xe không hợp lệ - đã gửi thông báo cho client",
                    plate
                }
            );
        } 
    }
    catch(err){
        console.error(err);
        res.status(500).json({ error: "Server lỗi, vui lòng thử lại sau" });
    }
}