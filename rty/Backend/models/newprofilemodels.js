// models/userModel.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  phoneNumber: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  birthday: { type: Date },
  gender: { type: String, enum: ['Male', 'Female', 'Other'] },
  address: { type: String },
  location: { type: String }, // district
  profilePhoto: { type: String } // Store URL or path of the profile photo
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
