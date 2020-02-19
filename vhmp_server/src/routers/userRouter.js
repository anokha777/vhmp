const express = require('express');

const userRouter = express.Router();
const userController = require('../controllers/userController');

userRouter.route('/user/register')
  .post(userController.registerUser);

userRouter.route('/user/login')
  .post(userController.loginUser);

userRouter.route('/user/logout')
  .get(userController.logoutUser);

userRouter.route('/nearby/:lng/:lat')
  .get(userController.nearByServiceCenter);

userRouter.route('/byid/:id')
  .get(userController.getUserById);

userRouter.route('/byusername/:username')
  .get(userController.getUserByName);

module.exports = userRouter;
