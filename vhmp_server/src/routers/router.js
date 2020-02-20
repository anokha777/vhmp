const express = require('express');

const appRouter = express.Router();
const userController = require('../controllers/userController');
const carController = require('../controllers/carController');

appRouter.route('/user/register')
  .post(userController.registerUser);

appRouter.route('/user/login')
  .post(userController.loginUser);

appRouter.route('/user/logout')
  .get(userController.logoutUser);

appRouter.route('/nearby/:lng/:lat')
  .get(userController.nearByServiceCenter);

appRouter.route('/car/diagnose/:userid')
  .get(carController.diagnoseCar);
  
appRouter.route('/car/issue')
  .post(carController.carIssueRequestSubmit);

appRouter.route('/car/issue/:userid') // userid is of service center
  .get(carController.getCarIssueRequestListByServiceCenterUserid);

appRouter.route('/byid/:id')
  .get(userController.getUserById);

appRouter.route('/byusername/:username')
  .get(userController.getUserByName);

module.exports = appRouter;
