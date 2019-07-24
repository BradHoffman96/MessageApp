const passport = require('passport');
require('../config/passport')(passport);
const router = require('express').Router();
const jwt = require('jwt-simple');
const multer = require('multer');
const fs = require('fs');
const path = require('path');

const Group = require('../models/group.js');
const User = require('../models/user.js');

var getGroupMembers = async function(group) {

  var members = [];
  for (let userId of group.members) {
    await User.findById(userId, function(err, user) {
      if (err) throw err;

      if (user) {
        var tempUser = user;
        tempUser.password = undefined;
        members.push(tempUser);
      }
    });
  }
  
  return members;
}

router.post("/", /*passport.authenticate('jwt', {session:false}),*/ function(req, res) {

  const newGroup = new Group({
    //owner: req.user.id,
    name: req.body.name,
    topic: req.body.topic,
    members: []
  });

  newGroup.save(function(err, group) {
    if (err) throw err;

    if (group) {
      res.status(200).json({success: true, msg: "Group created.", id: group._id});
    } else {
      res.status(400).json({success: false, msg: "Error creating group."});
    }
  });
});

router.post("/:id", passport.authenticate('jwt', {session: false}), function(req, res) {
  var groupId = req.params.id;

  Group.findById(groupId, function(err, group) {
    if (err) throw err;


    if (group) {
      if (!group.members.includes(req.user._id)) {
        return res.status(500).json({success: false, msg: "You are not authorized to edit this group."});
      }

      group.name = req.body.name;
      group.topic = req.body.topic;

      group.save(function(err, newGroup) {
        if (err) throw err;

        /*
        if (!fs.existsSync('./images')) {
          console.log("Creating images folder.");
          fs.mkdirSync('./images');
        }

        var dir = "./images/" + newGroup._id;
        if (!fs.existsSync(dir)) {
          console.log("Creating dir:" + dir);
          fs.mkdirSync(dir);
        }

        //upload image
        fs.writeFile(dir + "/group.png", new Buffer(req.body.image, 'base64'), function(err) {
          if (err) throw err;

          console.log("File uploaded!")

          if (newGroup) {
            return res.status(200).json({success: true, msg: "Group successfully updated."});
          } else {
            return res.status(400).json({success: false, msg: "Something went wrong."});
          }
        });
        */

        if (newGroup) {
          var members = getGroupMembers(newGroup);

          var tempGroup = newGroup.toObject();
          tempGroup.members = members;

          return res.status(200).json({success: true, msg: "Group successfully updated.", newGroup: tempGroup});
        } else {
          return res.status(400).json({success: false, msg: "Something went wrong."});
        }
      });
    } else {
      res.status(400).json({success: false, msg: "Could not find group."});
    }
  });
});

router.get("/:id", passport.authenticate('jwt', {session: false}), function (req, res) {
  var groupId = req.params.id;

  Group.findById(groupId, function(err, group) {
    if (err) throw err;

    if (group) {
      var members = getGroupMembers(group);
        
      var tempGroup = group.toObject();
      tempGroup.members = members;
      console.log(tempGroup);

      res.status(200).json({success: true, group: tempGroup});
    } else {
      res.status(400).json({success: false, msg: "Something went wrong getting group."});
    }
  });
});

router.get("/:id/image", passport.authenticate('jwt', {session: false}), function(req, res) {
  var groupId = req.params.id;

  var rootDir = path.join(__dirname, '../images', String(groupId), "group.png");

  if (!fs.existsSync(rootDir)) {
    console.log("Does not exist: " + rootDir);
    res.status(400).json({success: false, msg:"Image cannot be found"});
  } else {
    res.sendFile(rootDir, {success: true, msg: "Found image for: " + req.user.email}, function(err) {
      if (err) {
        return res.status(500).json({success: false, msg: "Something went wrong while retrieiving image."});
      } else {
        console.log("Profile Image sent for: " + req.user.email);
      }
    });
  }
});

router.get("/:id/members", passport.authenticate('jwt', {session: false}), function(req, res) {
  var groupId = req.params.id;

  Group.findById(groupId, async function(err, group) {
    if (err) throw err;
    console.log(group);


    res.status(200).json({success: true, members: members});
  });
});

module.exports = router;
