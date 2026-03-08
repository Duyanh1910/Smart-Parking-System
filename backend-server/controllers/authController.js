const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.login = async (req,res) => {
    try{
        console.log(req.body);
        const {username, password} = req.body;
        const sql = "SELECT * FROM users WHERE username = ?";   
        const [results] = await db.query(sql,[username]);
        if(results.length ===0){
            return res.status(401).json({
                error: "Sai tài khoản hoặc mật khẩu",
                message: "Sai tài khoản hoặc mật khẩu"
            })
        }
        const user = results[0];
        const match = await bcrypt.compare(password, user.password);
        if (!match) {
            return res.status(401).json({
                error: "Sai mật khẩu, vui lòng nhập lại",
                message: "Sai mật khẩu, vui lòng nhập lại"
            });
        }
        const token = jwt.sign(
            { id: user.id, username: user.username },
            "SECRET_KEY",
            { expiresIn: "1h" }
        );
        console.log(token);
        res.json({ message: "Đăng nhập thành công!", token: token,username:user.username });
    }
    catch(err){
        console.error(err);
        res.status(500).json({ error: "Server lỗi, vui lòng thử lại sau" });
    }
};
