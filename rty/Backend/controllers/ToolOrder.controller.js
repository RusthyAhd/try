const CustomResponse = require("../utils/custom.response");
const ToolModel = require('../models/Tool.model');
const ToolOrderModel = require('../models/ToolOrder.model');
const User = require('../models/newprofilemodels'); // Import the User model

const mongoose = require('mongoose'); // Import mongoose to use ObjectId

exports.addNewOrder = async (req, res) => {
  try {
    const {
      order_id,
      tool_id,
      shop_id,
      customer_id, // This will be the phone number
      title,
      qty,
      days,
      total_price,
      status,
      date
    } = req.body;

    // Fetch user details using phone number
    const user = await User.findOne({ phoneNumber: customer_id });
    if (!user) {
      return res.status(404).send(
        new CustomResponse(
          404,
          'User not found'
        )
      );
    }

    // Create new order
    const newToolOrder = new ToolOrderModel({
      order_id,
      tool_id,
      shop_id,
      customer_id: user._id, // Use user's _id
      customer_name: user.fullName, // Use user's fullName
      customer_address: user.address, // Use user's address
      customer_location: user.location, // Use user's location
      customer_number: user.phoneNumber, // Use user's phoneNumber
      title,
      qty,
      days,
      total_price,
      status,
      date: new Date(date)
    });

    await newToolOrder.save();

    res.status(200).send(
      new CustomResponse(
        200,
        'Order created successfully',
        { order_id }
      )
    );

  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).send(
      new CustomResponse(
        500,
        'Failed to create order',
        { error: error.message }
      )
    );
  }
};

exports.changeStatus = async (req, res, next) => {

    try {

        const { order_id, status, reason } = req.body;

        if(!order_id || !status){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'All fields are required!'
                )
            );
        }

        if (status === 'reject' && !reason) {
            return res.status(400).send(
                new CustomResponse(400, 'Reason is required to reject order!')
            );
        }

        let order = await ToolOrderModel.findOne({order_id});

        if (!order){
            return res.status(404).send(
                new CustomResponse(
                    404,
                    `Order with ID ${order_id} not found!`
                )
            )
        }

        await ToolOrderModel.updateOne(
            {order_id},
            {
                status:status,
                reject_reason: reason || ""
            }
        );

        //⚠️ sending sms alert

        const message= `Dear customer (${order.customer_name}), Your order (ID : ${order_id}) ${order.title} is ${status} by ${order.shop_id}`

        await OTPGateWay.sentSMS(message, order.customer_number)

        // return success response
        res.status(200).send(
            new CustomResponse(
                200,
                'Order status update successfully',
            )
        )

    }catch (error){
        console.error('Error change order status :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to change order status!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.getAllOrdersByShopId = async (req, res, next) => {

    try {
        const { shop_id } = req.params;

        if(!shop_id){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Shop id is required!'
                )
            );
        }

        let list = await ToolOrderModel.find({shop_id});

        // return success response
        res.status(200).send(
            new CustomResponse(
                200,
                'Orders find successfully',
                list
            )
        )


    }catch (error){
        console.error('Error getting order :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to get order!',
                {
                    error: error.message
                }
            )
        )
    }

}


exports.findOrderByStatusAndShopId = async (req, res, next) => {

    try {

        const { shop_id, status } = req.query;

        if(!shop_id || !status){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Shop is and status are required!'
                )
            );
        }

        console.log(shop_id)
        console.log(status)

        let list = await ToolOrderModel.find({shop_id:shop_id, status:status });

        // return success response
        res.status(200).send(
            new CustomResponse(
                200,
                'Orders find successfully',
                list
            )
        )

    }catch (error) {
        console.error('Error getting order :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to get order!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.findOrdersDateOrId = async (req, res, next) => {

    const { date, order_id } = req.body;

    try {

        // Validate that at least one of date or order_id is provided
        if (!date && !order_id) {
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'Please provide either date or order_id to search orders',
                )
            )
        }

        // Construct the query based on the parameters provided
        let query = {};

        if (order_id) {
            // Search by order_id if provided
            query.order_id = order_id;
        }

        if (date) {
            // Convert to a Date object
            const searchDate = new Date(date);
            // Search by date (ensure only the date part is compared)
            query.date = {
                $gte: new Date(searchDate.setHours(0, 0, 0)), // Start of the day
                $lt: new Date(searchDate.setHours(23, 59, 59))   // End of the day
            };
        }

        // Find orders based on the constructed query
        const orders = await ToolOrderModel.find(query);

        // return success response
        res.status(200).send(
            new CustomResponse(
                200,
                'Orders find successfully',
                orders
            )
        )

    }catch (error) {
        console.error('Error getting order :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to get order!',
                {
                    error: error.message
                }
            )
        )
    }

}


exports.getAllUserOrdersById = async (req, res, next) => {

    try {

        const { user_id } = req.query;

        if (!user_id){
            return res.status(400).send(
                new CustomResponse(
                    400,
                    'User id is required!'
                )
            )
        }

        let orders = await this.getToolOrders(user_id);

        return res.status(200).send(
            new CustomResponse(
                200,
                'User orders found successfully.',
                orders
            )
        )

    }catch (error){
        console.error('Error getting orders :', error);

        return res.status(500).send(
            new CustomResponse(
                500,
                'Failed to get orders!',
                {
                    error: error.message
                }
            )
        )
    }

}

exports.getToolOrders = async (id) => {

    return await ToolOrderModel.find({customer_id:id});

}