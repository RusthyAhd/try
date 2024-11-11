const express = require('express'); // Import express package
const ToolController = require('../controllers/Tool.controller');


const router = express.Router();

router.post('/new/:shop_email',  ToolController.addNewTool)

router.get('/get/all/:shop_id', ToolController.getAllTools)

router.get('/get/:tool_id',  ToolController.getAllToolById)

router.put('/update/:tool_id',  ToolController.updateTool)

router.delete('/delete/:tool_id', ToolController.deleteTool)

module.exports = router;
