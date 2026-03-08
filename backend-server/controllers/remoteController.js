const express = require("express");
const router = express.Router();
const db = require('../config/db');
const axios = require("axios");
exports.doorStatus = async (req,res)=>{
    try{
        return res.json(
            {
                door_status
            }
        );
    }
    catch(err){
        console.error(err);
        res.status(500).json({ error: "Server lỗi, vui lòng thử lại sau" });
    }
}
exports.plateNumber = async (req,res)=>{
    try{
        return res.json(
            {
                plate
            }
        );
    }
    catch(err){
        console.error(err);
        res.status(500).json({ error: "Server lỗi, vui lòng thử lại sau" });
    }
}
exports.openDoor = async (req,res)=>{
    try{
        return res.json(
            {
                message: "Đang mở"
            }
        );
    }
    catch(err){
        console.error(err);
        res.status(500).json({ error: "Server lỗi, vui lòng thử lại sau" });
    }
}
exports.closeDoor = async (req,res)=>{
    try{
        return res.json(
            {
                message: "Đang đóng"
            }
        );
    }
    catch(err){
        console.error(err);
        res.status(500).json({ error: "Server lỗi, vui lòng thử lại sau" });
    }
}
exports.stopDoor = async (req,res)=>{
    try{
        return res.json(
            {
                message: "Đang dừng"
            }
        );
    }
    catch(err){
        console.error(err);
        res.status(500).json({ error: "Server lỗi, vui lòng thử lại sau" });
    }
}


