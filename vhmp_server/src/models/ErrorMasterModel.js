const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const ErrorMasterSchema = new Schema({
  errorCode: { type: String, require: true },
  description: { type: String, require: true },
  meaning: { type: String, required: true },
  mainSymptoms: { type: String, required: true },
  possibleCauses: { type: String, required: true },
  diagnosticSteps: { type: String, required:  true },
  createDatetime: { type: Date, default: Date.now() },
});

module.exports = mongoose.model('errormaster', ErrorMasterSchema);
