const mongoose = require('mongoose');
const Schema = mongoose.Schema;

var GroupSchema = new Schema({
  name: {
    type: String,
    required: true
  },
  topic: {
    type: String
  },
  owner: {
    type: String,
    //required: true
  },
  image: String,
  members: [String]
});

module.exports = mongoose.model('Groups', GroupSchema);
