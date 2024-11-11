const express = require('express'); // Import express package
const ToolOrderController = require('../controllers/ToolOrder.controller');


const router = express.Router();

router.post('/new', ToolOrderController.addNewOrder)

router.put('/change/status', ToolOrderController.changeStatus)

router.get('/get/all/status',  ToolOrderController.findOrderByStatusAndShopId)

router.get('/get/user/all',  ToolOrderController.getAllUserOrdersById)

router.post('/get/all/date/order',  ToolOrderController.findOrdersDateOrId)

router.get('/get/all/:shop_id',  ToolOrderController.getAllOrdersByShopId)

module.exports = router;
