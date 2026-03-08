const express = require("express");
const router = express.Router();
const db = require('../config/db');

exports.history = async (req,res) =>{
    try{
        const sql = 'SELECT * FROM parking_id ORDER BY checkIn_time DESC';
        const [results] = await db.query(sql);
        return res.json(
            {
                status: "OK",
                message: "Truy vấn thành công lịch sử!",
                results
            }
        );
    }
    catch(err){
        console.error(err);
        res.status(500).json({ error: "Server lỗi, vui lòng thử lại sau" });
    }
}