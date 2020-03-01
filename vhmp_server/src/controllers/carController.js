const mongoose = require('mongoose');
const ObjectId = require('mongoose').Types.ObjectId;
const config = require('../config/config');

// const CarIssueModel = require('../models/CarIssueModel');
// const ErrorMasterModel = require('../models/ErrorMasterModel');
const UserModel = require('../models/UserModel');
const CarIssueRequestModel = require('../models/CarIssueRequestModel');
const CarErrorHistoryModel = require('../models/CarErrorHistoryModel');

require('../models/CarIssueModel');
const CarIssueModel= mongoose.model('carissue');

require('../models/ErrorMasterModel');
const ErrorMasterModel= mongoose.model('errormaster');

const carController = {
  updateCarAppointmentState: (req, res, next) => {
      CarIssueRequestModel.findByIdAndUpdate(req.params.carIssueRequestModelId, {requestState: req.body.requestState}, {new: true}, function(err, model) {
      if(err) {
        throw err;
      } else {
        return res.status(200).json(model);
      }
    });
  },

  diagnoseCar: (req, res, next) => {
    CarIssueModel.find({ carOwner: req.params.userid }, (err, carIssue) => {
      if (err) {
        throw err;
      } else if(carIssue.length < 1) {
        return res.status(200).json([]);
      } else {
        ErrorMasterModel.findById(carIssue[0].carError, (err, carErrorDetails) => {
          UserModel.findById(carIssue[0].carOwner, (err, carOwnerDatails) => {
            return res.status(200).json([{
              carIssueId: carIssue[0]._id,
              carOwnerDatail: {
                id: carOwnerDatails._id,
                name: carOwnerDatails.name,
                mobileNum: carOwnerDatails.mobileNum,
                username: carOwnerDatails.username,
                role: carOwnerDatails.role, 
                vehicleModel: carOwnerDatails.vehicleModel
              },
              carErrorDetails
            }
          ]);
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
        requesterCarOwner: req.body.requesterCarOwner,
        selectedDate: req.body.selectedDate,
        selectedTime: req.body.selectedTime
      }).then((response) => {
        CarErrorHistoryModel.create({
          carIssue: req.body.currentCarIssue,
          carOwner: req.body.requesterCarOwner
        });
          res.set('Content-Type', 'application/json');
          res.status(200).send({ response });
      })
    } catch (error) {
      console.log('error--------------', error);
      res.status(500).send({ msg: 'Error in carIssueRequestSubmit.' });
    }
  },

  getMyCarIssueRequestList: (req, res, next) => {
    let myCarIssueRequestList = [];
    CarIssueRequestModel.find({ requesterCarOwner: req.params.userid }).then(carIssueRequestModelList => {
      console.log('carIssueRequestModelList------------', carIssueRequestModelList.length);
      if(carIssueRequestModelList.length > 0) {
        carIssueRequestModelList.forEach(function(ci) {
          myCarIssueRequestList.push(CarIssueModel.findById(ci.currentCarIssue).then((carIssue) => {
            return UserModel.findById(ci.selectedServiceCenter).then((serviceCenterDetail) => { // service center user details
              return ErrorMasterModel.findById(carIssue.carError).then((carErrorDetails) => {
                return {
                  carIssueRequestId: ci._id,
                  // currentCarIssue: {type: Schema.Types.ObjectId, ref: 'carissue'},
                  selectedServiceCenter: serviceCenterDetail,
                  requesterCarOwner: ci.requesterCarOwner,
                  selectedDate: ci.selectedDate,
                  selectedTime: ci.selectedTime,
                  requestState: ci.requestState,
                  createDatetime: ci.createDatetime,
                  carErrorDetails
                };
              });
            });
          }));
        });
        return Promise.all(myCarIssueRequestList);
      }
    }).then(function(myCarIssueRequestList) {
      res.set('Content-Type', 'application/json');
      res.status(200).send(myCarIssueRequestList);
    }).catch(function(error) {
      res.status(500).send('Fetching issue logged by car owner failed...', error);
  });
  },

  getCarIssueRequestListForServiceCenter: (req, res, next) => {
    let carIssueRequestList = [];
    CarIssueRequestModel.find({ selectedServiceCenter: req.params.userid }).then(carIssueList => {
      // console.log('carIssueList--------------', carIssueList);

        if(carIssueList.length > 0) {
          carIssueList.forEach(function(ci) {
            carIssueRequestList.push(CarIssueModel.findById(ci.currentCarIssue).then((carIssue) => {
              return UserModel.findById(carIssue.carOwner).then((carOwnerDatails) => {
                return ErrorMasterModel.findById(carIssue.carError).then((carErrorDetails) => {
                  return {
                    carIssueRequestModelId: ci._id,
                    requesterCarOwner: ci.requesterCarOwner,
                    selectedDate: ci.selectedDate,
                    selectedTime: ci.selectedTime,
                    requestState: ci.requestState,
                    createDatetime: ci.createDatetime,
                    carOwnerDatails: {
                      _id: carOwnerDatails._id,
                      name: carOwnerDatails.name,
                      mobileNum: carOwnerDatails.mobileNum,
                      username: carOwnerDatails.username,
                      vehicleModel: carOwnerDatails.vehicleModel,
                      role: carOwnerDatails.role
                    },
                    carErrorDetails
                  };
                });
              });
            }));
          });
          return Promise.all(carIssueRequestList);
        }
    }).then(function(carIssueRequestList) {
        console.log('carIssueRequestList--------');
      if(carIssueRequestList) {
        res.set('Content-Type', 'application/json');
        res.status(200).send(carIssueRequestList);
      } else {
        res.set('Content-Type', 'application/json');
        res.status(200).send([]);
      }
        
      }).catch(function(error) {
        res.status(500).send('Fetching issue logged by car owner failed...', error);
    });
  },

  getCarIssueHistoryListForCarOwner: (req, res, next) => {
    console.log('req.params.userid-------------', req.params.userid);
    let carIssueHistoryList = [];
    CarErrorHistoryModel.find({ carOwner: req.params.userid }).then(carIssueHistoryListForCarOwner => {
      // console.log('carIssueHistoryListForCarOwner--------------', carIssueHistoryListForCarOwner);

        if(carIssueHistoryListForCarOwner.length > 0) {
          carIssueHistoryListForCarOwner.forEach(function(ci) {
            carIssueHistoryList.push(CarIssueModel.findById(ci.carIssue).then((carIssue) => {
              // return UserModel.findById(carIssue.carOwner).then((carOwnerDatails) => {
                return ErrorMasterModel.findById(carIssue.carError).then((carErrorDetails) => {
                  return {
                    carIssueHistoryId: ci._id,
                    createDatetime: ci.createDatetime,
                    carErrorDetails
                  };
                });
              // });
            }));
          });
          return Promise.all(carIssueHistoryList);
        }
    }).then(function(carIssueHistoryList) {
      console.log('carIssueHistoryList--------');
      if(carIssueHistoryList) {
        res.set('Content-Type', 'application/json');
        res.status(200).send(carIssueHistoryList);
      } else {
        res.set('Content-Type', 'application/json');
        res.status(200).send([]);
      }
      }).catch(function(error) {
        res.status(500).send('Fetching car issue history for car owner failed...', error);
    });
  }
  
}

module.exports = carController;
