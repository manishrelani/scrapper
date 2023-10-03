const express = require("express");
const router = express.Router();
const productsController = require("../controllers/products.controller");


router.get("/search_product", productsController.findAllProducts);


module.exports = router;
