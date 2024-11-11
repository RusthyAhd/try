const {verify} = require("jsonwebtoken");
const CustomResponse = require('../utils/custom.response');
const jwt = require('jsonwebtoken');
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
  
    if (!token) {
      return res.status(404).json({
        status: 404,
        message: 'Token not found!'
      });
    }
  
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decoded;
      next();
    } catch (error) {
      return res.status(401).json({
        status: 401,
        message: 'Invalid token'
      });
    }
  };

exports.verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    if (!authHeader) {
      return res.status(401).json({
        status: 401,
        message: "No authorization header"
      });
    }

    const token = authHeader.replace('Bearer ', '').trim();
    
    console.log('Verifying token with secret:', process.env.JWT_SECRET);
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    console.error('Token verification error:', error);
    return res.status(401).json({
      status: 401, 
      message: "Invalid or expired token"
    });
  }
};