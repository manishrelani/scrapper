const puppeteer = require("puppeteer");

const website_2 = async (product_name) => {
  // headless and headfull
  const browser = await puppeteer.launch({ headless: 'new' });
  //   open new tab
  const page = await browser.newPage();
  //  navigate in tht new tab
  await page.goto("https://www.woolworths.com.au/shop/search");

  const inputSelector = "#wx-headerSearch"; // Using the ID selector
  await page.waitForSelector(inputSelector);
  await page.focus(inputSelector); // Focus on the input field
  await page.keyboard.type(product_name); // Type the desired word

  const buttonSelector = "#wx-button-header-search-find";
  await page.waitForSelector(buttonSelector);
  await page.click(buttonSelector);
  try {
    //wait for cards to load
    await page.waitForSelector(".product-tile-v2");
    // Extract data from each product card
    const products = await page.evaluate(() => {
      const productCards = Array.from(
        document.querySelectorAll(".product-tile-v2")
      );
      const subProducts = productCards.slice(0, 10);
      return subProducts.map((card) => {
        const name =
          card.querySelector(".product-title-link")?.textContent || "N/A";
        const price = card.querySelector(".primary")?.textContent || "N/A";

        const divElement = document.querySelector(".product-tile-v2--image");
        const aTag = divElement.querySelector("a");
        const link = aTag.getAttribute("href")
          ? `https://www.woolworths.com.au${aTag.getAttribute("href")}`
          : null;
        const imgTag = divElement.querySelector("img");
        const image = imgTag ? imgTag.getAttribute("src") : null;

        return { name, price, image, link };
      });
    });
    await browser.close();
    return products;
  } catch (error) {
    console.log("No such selector found.");
    await browser.close();
    return [];
  }
};

module.exports = {
  website_2,
};
