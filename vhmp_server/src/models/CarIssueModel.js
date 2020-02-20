const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const config = require('../config/config');

const CarIssueSchema = new Schema({
  carOwner: {type: Schema.Types.ObjectId, ref: 'user'},
  carError: {type: Schema.Types.ObjectId, ref: 'errormaster'},
  issueState: { type: String, default: config.ISSUE_UN_RESOLVED },
  createDatetime: { type: Date, default: Date.now() },
});
    
module.exports = mongoose.model('carissue', CarIssueSchema);
