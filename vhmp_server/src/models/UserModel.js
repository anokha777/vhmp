const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// const GeoSchema = new Schema({
//   type: { type: String, default: "Point" },
//   coordinates: { type: [Number], index: "2dsphere" }
// });
const GeoSchema = new Schema(
  { type: { type: String, default: 'Point' },
    coordinates: { type: [Number], index: '2dsphere' }
  },
  { _id: false }
);

const UserSchema = new Schema({
  name: { type: String, require: true },
  mobileNum: { type: String, require: true },
  username: { type: String, required : true },
  password: { type: String, required : true },
  vehicleNum: { type: String, required : true },
  createdAt: { type: Date, default: Date.now() },
  location: GeoSchema
});

// UserSchema.index({ location: '2dsphere' });
    
module.exports = mongoose.model('user', UserSchema);
