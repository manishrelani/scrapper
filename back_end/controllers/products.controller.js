const service = require("../services/products.service");

const findAllProducts = async (req, res, next) => {
  try {
    const product_name = req.query.product_name;

    if (product_name !== null && product_name.trim() !== "") {
      const result = await service.fetchAllProducts(product_name);
      if (result.message && result.stack) {
        throw result;
      } else if (result.length == 0) {
        return res.status(404).send({
          message: "Product not found",
        });
      } else {
        res.status(200).send(result);
      }
    } else {
      res.status(400).json({ message: "Product name required" });
    }
  } catch (error) {
    res.send(error);
  }
};

module.exports = {
  findAllProducts,
};
