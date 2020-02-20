const mongoose = require('mongoose');
const ObjectId = require('mongoose').Types.ObjectId;
const config = require('../config/config');

// const CarIssueModel = require('../models/CarIssueModel');
// const ErrorMasterModel = require('../models/ErrorMasterModel');
const UserModel = require('../models/UserModel');
const CarIssueRequestModel = require('../models/CarIssueRequestModel');

require('../models/CarIssueModel');
const CarIssueModel= mongoose.model('carissue');

require('../models/ErrorMasterModel');
const ErrorMasterModel= mongoose.model('errormaster');

const carController = {
  diagnoseCar: (req, res, next) => {
    CarIssueModel.find({ carOwner: req.params.userid }, (err, carIssue) => {
      if (err) {
        throw err;
      } else {
        ErrorMasterModel.findById(carIssue[0].carError, (err, carErrorDetails) => {
          UserModel.findById(carIssue[0].carOwner, (err, carOwnerDatails) => {
            return res.status(200).json({
              id: carIssue[0]._id,
              carOwnerDatail: {
                name: carOwnerDatails.name,
                mobileNum: carOwnerDatails.mobileNum,
                username: carOwnerDatails.username,
                role: carOwnerDatails.role, 
                vehicleModel: carOwnerDatails.vehicleModel
              },
              carErrorDetails
            });
          });
        });
        
      }
    });
  },

  carIssueRequestSubmit: (req, res, next) => {
    console.log('carIssueRequestSubmit req.body----------------------', req.body);
    const saltRounds = 10;
    try {
      CarIssueRequestModel.create({
        currentCarIssue: req.body.currentCarIssue,
        selectedServiceCenter: req.body.selectedServiceCenter,
        selectedDate: new Date(req.body.selectedDate),
        selectedTime: req.body.selectedTime
      }).then(response => {
          res.set('Content-Type', 'application/json');
          res.status(201).send({ response });
      })
    } catch (error) {
      console.log('error--------------', error);
      res.status(500).send({ msg: 'Error in carIssueRequestSubmit.' });
    }
  },

  getCarIssueRequestListByServiceCenterUserid: (req, res, next) => {
    CarIssueRequestModel.find({ selectedServiceCenter: req.params.userid }, (err, carIssueList) => {
      console.log('carIssueList----', carIssueList);
      let carIssueRequestList = [];
      if (err) {
        throw err;
      } else {
        if(carIssueList.length > 0) {
          carIssueList.forEach(carIssueReq => {
            CarIssueModel.findById(carIssueReq.currentCarIssue, (err, carErrorDetails) => {
              console.log('carErrorDetails----------------------', carErrorDetails);
              UserModel.findById(carErrorDetails.carOwner, (err, carOwnerDatails) => {
                carIssueRequestList.push({
                  _id: carIssueReq.selectedServiceCenter,
                  carOwnerDatail: {
                    name: carOwnerDatails.name,
                    mobileNum: carOwnerDatails.mobileNum,
                    username: carOwnerDatails.username,
                    role: carOwnerDatails.role, 
                    vehicleModel: carOwnerDatails.vehicleModel
                  },
                  carErrorDetails
                });
                
              });
            }).then(() => {
              return res.status(200).json({ carIssueRequestList });
            });
          });
        }
        
        
      }
    });
  }
  
}

module.exports = carController;
