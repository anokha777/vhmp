const express = require('express');
const helmet = require('helmet');
const bodyParser = require('body-parser');
const cors = require('cors');

const userRouter = require('./src/routers/router');

const app = express();
app.use(helmet());
app.use(cors());

//Body Parser middleware
app.use(bodyParser.urlencoded({extended:false}));
app.use(bodyParser.json());


const port = 5000;


app.use('/api', userRouter);

app.use('/', (req, res) => {
  res.send('VHMP server OK!!!');
})

app.use((error, req, res, next) => {
  if (error) res.status(500).send({ statusCode: error.statusCode, msg: error.error.msg });
  next();
});

app.use((req, res) => {
  res.status(404).send('NOT Found.');
});

require('./src/db/dbConnect');

app.listen(port, () => {
  console.log('User mgt server listening at port- ', port);
});
