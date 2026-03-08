const express = require("express");
const router = express.Router();
const db = require('../config/db');
const axios = require("axios");
const dayjs = require('dayjs');
const utc = require('dayjs/plugin/utc');
const timezone = require('dayjs/plugin/timezone');
const admin = require("../config/firebase");

dayjs.extend(utc);
dayjs.extend(timezone);
exports.approve = async(req,res) =>{
    try{
        const plate = req.body.plate;
        console.log(`Biển số xe: ${plate}`);
        if(!plate){
            return res.json({
                status: "ERROR",
                message: "Missing plate"
            });
        }
        const sql1 = "INSERT INTO vehicle(plate_id) VALUES(?)";
        const results1 = await db.execute(sql1,[plate]);
        const sql2 = "INSERT INTO parking_id(plate_id,checkIn_time) VALUES(?,?)";
        const now = dayjs().tz('Asia/Ho_Chi_Minh').format('YYYY-MM-DD HH:mm:ss');
        const results2 = await db.execute(sql2,[plate,now]);
        console.log(`Biển số xe: ${plate} đã được chấp nhận`);
        return res.json(
            {
                status: "ALLOWED",
                message: "Biển số xe hợp lệ",
                plate
            }
        );  
    }
    catch(err){
        console.error(err);
        res.status(500).json({ error: "Server lỗi, vui lòng thử lại sau" });
    }
}