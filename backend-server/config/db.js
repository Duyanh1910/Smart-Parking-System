const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: 'duyanh19102004',
  database: 'nha_xe_thong_minh'
});

module.exports = pool;