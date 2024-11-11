// routes/userRoutes.js
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/newprofilemodels'); // Add this import
const { createOrUpdateProfile, getUserProfile } = require('../controllers/newProfilecontroller');
const { verifyToken } = require('../middleware/AuthMiddleware');

// Add login route to generate token
router.post('/login', async (req, res) => {
  try {
    const { phoneNumber } = req.body;
    
    // Create token with same structure as existing
    const token = jwt.sign(
      { 
        phoneNumber: phoneNumber
      },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(200).json({
      status: 200,
      token: token,
      phoneNumber: phoneNumber
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      status: 500,
      message: 'Error during login'
    });
  }
});

router.post('/cu', verifyToken, async (req, res) => {
  try {
    const result = await createOrUpdateProfile(req, res);
    console.log('Profile creation result:', result);
    return result;
  } catch (error) {
    console.error('Profile creation error:', error);
    res.status(500).json({
      status: 500,
      message: error.message || 'Error creating/updating profile'
    });
  }
});

// Update get profile route
router.get('/:phoneNumber', async (req, res) => {
  try {
    const { phoneNumber } = req.params;
    console.log('Fetching profile for:', phoneNumber);

    const user = await User.findOne({ phoneNumber });
    console.log('Found user:', user);

    if (!user) {
      return res.status(404).json({ 
        status: 404,
        message: 'User not found' 
      });
    }

    return res.status(200).json({
      status: 200,
      data: { user }
    });
  } catch (error) {
    console.error('Profile fetch error:', error);
    return res.status(500).json({ 
      status: 500,
      message: error.message 
    });
  }
});

router.post('/profile/cu', verifyToken, async (req, res) => {
  try {
    const { fullName, phoneNumber, email, birthday, gender, address, location, profilePhoto } = req.body;
    
    // Find existing user or create new one
    let user = await User.findOneAndUpdate(
      { phoneNumber },
      {
        $set: {
          fullName,
          email,
          birthday: new Date(birthday),
          gender,
          address,
          location,
          profilePhoto,
          updatedAt: new Date()
        }
      },
      { new: true, upsert: true }
    );

    console.log('Saved user:', user);

    res.status(200).json({
      status: 200,
      message: 'Profile saved successfully',
      data: { user }
    });
  } catch (error) {
    console.error('Save error:', error);
    res.status(500).json({
      status: 500,
      message: error.message
    });
  }
});

module.exports = router;
