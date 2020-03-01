const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const CarErrorHistorySchema = new Schema({
  carIssue: {type: Schema.Types.ObjectId, ref: 'carissue'},
  carOwner: {type: Schema.Types.ObjectId, ref: 'user'},
  createDatetime: { type: Date, default: Date.now() },
});

module.exports = mongoose.model('carErrorHistory', CarErrorHistorySchema);
