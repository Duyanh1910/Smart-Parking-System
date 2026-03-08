const express = require("express");
const router = express.Router();
const db = require('../config/db');

exports.notify = async (req,res) =>{
    try{
        const sql = 'SELECT * FROM notification ORDER BY id DESC';
        const [results] = await db.query(sql);
        console.log(results);
        return res.json(
            {
                status: "OK",
                message: "Truy vấn thành công thông báo!",
                results
            }
        );
    }
    catch(err){
        console.error(err);
        res.status(500).json({ error: "Server lỗi, vui lòng thử lại sau" });
    }
}