const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const config = require('../config/config');

const CarIssueRequestSchema = new Schema({
  currentCarIssue: {type: Schema.Types.ObjectId, ref: 'carissue'},
  selectedServiceCenter: {type: Schema.Types.ObjectId, ref: 'user'},
  selectedDate: { type: Date, require: true },
  selectedTime: { type: String, required: true },
  requestState: { type: String, default: config.REQ_INITIAL_STATE },
  createDatetime: { type: Date, default: Date.now() },
});

module.exports = mongoose.model('carIssueRequest', CarIssueRequestSchema);
