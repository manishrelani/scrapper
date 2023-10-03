require("dotenv").config(); //import env variables
const express = require("express");
const cors = require("cors"); // for handling Cross-Origin Resource Sharing.
const app = express();

app.use(express.json());

app.use(cors()); // Enable CORS for all routes

app.use(function (req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "DELETE, PUT, GET, POST"); //allowed HTTP methods

  // allowed headers
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  );
  res.header(
    "Access-Control-Expose-Headers",
    "Access-Token, Uid,x-pagination-total-count,x-pagination-page-count,x-pagination-start-record,x-pagination-end-record"
  );
  // Move to the next middleware in the chain
  next();
});

const routes = require("./routes");

app.use("/", routes);

let port = process.env.PORT || 3002;

app.listen(port, () => {
  console.log(`Server started at port ${port}`);
});
