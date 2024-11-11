const express = require('express'); // Import express package
const OwnerController = require('../controllers/Owner.Controller');

const ServiceProviderController = require("../controllers/ServiceProvider.controller"); // Import the controller

const router = express.Router();

// Update POST route for shop registration
router.post('/registration', OwnerController.register);

router.post('/get/all/category/location',  OwnerController.getShopsByCategoryAndLocation);

router.put('/update/:id',  OwnerController.updateShopDetails);

router.post('/login/owner',  OwnerController.login);

router.get('/find', OwnerController.findOwnerByEmail)

module.exports = router;
