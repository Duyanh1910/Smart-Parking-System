const express = require("express");
const router = express.Router();
const authController = require('../controllers/authController');
const plateController = require('../controllers/plateController');
const parkingController = require('../controllers/parkingController');
const remoteController = require('../controllers/remoteController');
const notifyController = require('../controllers/notificationController');
const approveController = require('../controllers/approveController');

router.post('/login',authController.login);
router.post('/plate',plateController.plate);
router.get('/history',parkingController.history);
router.get('/notify',notifyController.notify);
router.post('/approve',approveController.approve);

router.get('/door/status', remoteController.doorStatus);
router.get('/plate/number', remoteController.plateNumber);
router.post('/door/open', remoteController.openDoor);
router.post('/door/close', remoteController.closeDoor);
router.post('/door/stop', remoteController.stopDoor);

module.exports = router;