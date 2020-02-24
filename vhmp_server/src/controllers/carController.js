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
            // ,
            // {
            //   id: 'carIssue[0]._id',
            //   carOwnerDatail: {
            //     id: 'carOwnerDatails._id',
            //     name: 'carOwnerDatails.name',
            //     mobileNum: 'carOwnerDatails.mobileNum',
            //     username: 'carOwnerDatails.username',
            //     role: 'carOwnerDatails.role', 
            //     vehicleModel: 'carOwnerDatails.vehicleModel'
            //   },
            //   carErrorDetails: {
            //     errorCode: 'errorCode',
            //     description: 'description'
            //   }
            // }
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
        selectedDate: new Date(req.body.selectedDate),
        selectedTime: req.body.selectedTime
      }).then(response => {
          res.set('Content-Type', 'application/json');
          res.status(200).send({ response });
      })
    } catch (error) {
      console.log('error--------------', error);
      res.status(500).send({ msg: 'Error in carIssueRequestSubmit.' });
    }
  },

  getCarIssueRequestListByServiceCenterUserid: (req, res, next) => {
    let carIssueRequestList = [];
    CarIssueRequestModel.find({ selectedServiceCenter: req.params.userid }).then(carIssueList => {
      // console.log('carIssueList--------------', carIssueList);

        if(carIssueList.length > 0) {

          // let carIssueRequestList = [];
          carIssueList.forEach(function(ci) {
            carIssueRequestList.push(CarIssueModel.findById(ci.currentCarIssue).then((carIssue) => {
              return UserModel.findById(carIssue.carOwner).then((carOwnerDatails) => {
                return ErrorMasterModel.findById(carIssue.carError).then((carErrorDetails) => {
                  return {
                    _id: ci._id,
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
        res.send(carIssueRequestList);
      }).catch(function(error) {
        res.status(500).send('Fetching issue logged by car owner failed...', error);
    });
  }
  
}

module.exports = carController;
