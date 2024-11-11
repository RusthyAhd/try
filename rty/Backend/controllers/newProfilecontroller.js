// controllers/userController.js
const User = require('../models/newprofilemodels');

// Create or Update User Profile
exports.createOrUpdateProfile = async (req, res) => {
  try {
    const { fullName, phoneNumber, email, birthday, gender, address, location, profilePhoto } = req.body;
    console.log('Received profile data:', req.body);

    let user = await User.findOne({ phoneNumber });
    console.log('Existing user:', user);

    if (user) {
      // Update existing user
      const updateResult = await User.findOneAndUpdate(
        { phoneNumber },
        {
          fullName,
          email,
          birthday: new Date(birthday),
          gender,
          address,
          location,
          profilePhoto
        },
        { new: true }
      );
      console.log('Updated user:', updateResult);

      return res.status(200).json({
        status: 200,
        message: 'Profile updated successfully',
        data: { user: updateResult }
      });
    } else {
      // Create new user
      const newUser = new User({
        fullName,
        phoneNumber,
        email,
        birthday: new Date(birthday),
        gender,
        address,
        location,
        profilePhoto
      });
      const savedUser = await newUser.save();
      console.log('New user created:', savedUser);

      return res.status(201).json({
        status: 201,
        message: 'Profile created successfully',
        data: { user: savedUser }
      });
    }
  } catch (error) {
    console.error('Profile creation/update error:', error);
    return res.status(500).json({
      status: 500,
      message: error.message || 'Error creating/updating profile'
    });
  }
};

// Fetch User Profile by Phone Number
exports.getUserProfile = async (req, res) => {
  try {
    const { phoneNumber } = req.params;
    console.log('Fetching profile for:', phoneNumber); // Debug log

    const user = await User.findOne({ phoneNumber });
    console.log('Found user:', user); // Debug log

    if (!user) {
      return res.status(404).json({
        status: 404,
        message: 'User not found'
      });
    }

    res.status(200).json({
      status: 200,
      data: { user }
    });
  } catch (error) {
    console.error('getUserProfile error:', error);
    res.status(500).json({
      status: 500,
      message: 'Server error'
    });
  }
};
