const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const Schema = mongoose.Schema;

const options = {
  userNewUrlParser: true
}

var users = mongoose.createConnection("mongodb://127.0.0.1:27017/HomieChat", options);

var UserSchema = new Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true},
  display_name: { type: String, required: true },
  birth_name: { type: String, required: true },
  pic_path: { type: String },
  created_at: Date
});

UserSchema.methods.comparePassword = function(password, callback) {
  bcrypt.compare(password, this.password, function (err, isMatch) {
    if (err) {
        return callback(err);
    }

    callback(null, isMatch);
  });
};

UserSchema.pre('save', function (next) {
  var user = this;

  if (this.isModified('password') || this.isNew) {
    bcrypt.genSalt(10, function(err, salt) {
      if (err) {
        return next(err);
      }

      bcrypt.hash(user.password, salt, function (err, hash)  {
        if (err) {
          return next(err);
        }

        user.password = hash;
        next();
      });
    });
  } else {
    return next();
  }
});

module.exports = users.model("User", UserSchema);
