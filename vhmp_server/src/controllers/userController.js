const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const geocoder = require('../utils/geoCoder');
const config = require('../config/config');

const UserModel = require('../models/UserModel');
// const UserModel = mongoose.model('user');

const userController = {

  nearByServiceCenter: (req, res, next) => {
    const { lng, lat } = req.params;
    console.log('req.params---', lng, lat);
    try {
      UserModel.aggregate().near({ 
        near: {
         'type': 'Point',
          'coordinates': [parseFloat(lng), parseFloat(lat)] }, 
          maxDistance: 100000,
          spherical: true, 
          distanceField: "dis" 
         }
         ).then(function(responseServiceCenters){
         res.send(responseServiceCenters);
        });
      } catch (error) {
          next();
      }
  },

  registerUser: (req, res, next) => {
    console.log('req.body----------------------------', req.body);
    const saltRounds = 10;
    try {
      UserModel.find({ username: req.body.username })
        .exec().then((user) => {
          if (user.length > 0) {
            res.status(409).send({ msg: 'User name already taken, Please try with other.' });
          } else {
            bcrypt.hash(req.body.password, saltRounds, function (err, hash) {
              if(req.body.role === config.ROLE_SERVICE_CENTER) {
                let cordFromAddress = '';
                geocoder.geocode(req.body.address, function(err, geocoderRes) {
                  console.log('---888----------------', geocoderRes);
                  cordFromAddress =  { type: 'point', coordinates: [ geocoderRes[0].longitude, geocoderRes[0].latitude ] };
                  UserModel.create({
                    name: req.body.name,
                    mobileNum: req.body.mobileNum,
                    username: req.body.username,
                    password: hash,
                    role: req.body.role,
                    address: req.body.address,
                    location: cordFromAddress
                    // location: { type: 'point', coordinates: [-80, 25.791] }
                  }).then(response => {
                      res.set('Content-Type', 'application/json');
                      res.status(201).send({
                        id: response._id,
                        name: response.name,
                        mobileNum: response.mobileNum,
                        username: response.username,
                        role: response.role,
                        address: response.address,
                        location: response.location,
                        createdAt: response.createdAt
                      });
                  })
                });
            } else {
              UserModel.create({
                name: req.body.name,
                mobileNum: req.body.mobileNum,
                username: req.body.username,
                password: hash,
                vehicleModel: req.body.vehicleModel,
                role: req.body.role
              }).then(response => {
                  res.set('Content-Type', 'application/json');
                  res.status(201).send({
                    id: response._id,
                    name: response.name,
                    mobileNum: response.mobileNum,
                    username: response.username,
                    vehicleModel: response.vehicleModel,
                    role: response.role,
                    createdAt: response.createdAt
                  });
              })
            }


            });
          }
        });
    } catch (error) {
      console.log('error--------------', error);
      res.status(500).send({ msg: 'Error in registration.' });
    }
  },

  logoutUser: (req, res, next) => {
    try {
      res.set('Content-Type', 'application/json');
      res.status(201).send({
        token: null,
        id: null,
        message: 'You have logged out successfully!!!'
      });
    } catch (error) {
      res.status(500).send({ msg: 'Error in logout' });
    }
  },

  loginUser: (req, res, next) => {
    UserModel.find({ username: req.body.username })
      .exec()
      .then((user) => {
        if (user.length < 1) {
          res.status(401).json({
            msg: 'Auth failed',
          });
        } else {
          bcrypt.compare(req.body.password, user[0].password, function (err, compareRes) {
            if (compareRes === true) {
              /* eslint no-underscore-dangle: ["error", { "allow": ["_id"] }] */
              const token = jwt.sign({ sub: user[0]._id, username: user[0].username }, config.secret, { expiresIn: '1h' });
              return res.status(200).json({
                msg: 'Auth successful',
                token,
                id: user[0]._id,
                username: user[0].username,
                name: user[0].name,
                mobileNum: user[0].mobileNum,
                username: user[0].username,
                role: user[0].role,
                vehicleModel: user[0].vehicleModel,
              });
            } else {
              res.status(401).json({
                msg: 'Auth failed',
              });
            }
          });
        }
      })
      .catch((error) => {
        res.status(401).send({
          msg: 'Auth failed',
        });
      });
  },

  getUserById: (req, res, next) => {
    UserModel.findById({ _id: req.params.id }, (err, user) => {
      if (err) {
        throw err;
      } else {
        return res.status(200).json({
          id: user._id,
          fname: user.fname,
          lname: user.lname,
          username: user.username,
          badge: user.badge,
          createdAt: user.createdAt,
        });
      }
    });
  },

  getUserByName: (req, res, next) => {
    UserModel.find({ username: req.params.username }, (err, user) => {
      if (err) {
        throw err;
      } else {
        return res.status(200).json({
          id: user[0]._id,
          fname: user[0].fname,
          lname: user[0].lname,
          username: user[0].username,
          badge: user[0].badge,
          createdAt: user[0].createdAt,
        });
      }
    });
  }

}

module.exports = userController;
