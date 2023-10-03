const puppeteer = require("puppeteer");

const website_1 = async (product_name) => {
  // headless and headfull
  const browser = await puppeteer.launch({ headless: "new" });
  //   open new tab
  const page = await browser.newPage();
  //  navigate in tht new tab
  await page.goto("https://www.coles.com.au/");

  const inputSelector = "#search-text-input"; // Using the ID selector
  await page.waitForSelector(inputSelector);
  await page.focus(inputSelector); // Focus on the input field
  await page.keyboard.type(product_name); // Type the desired word

  const buttonSelector = '[data-testid="search-box-clear-button"]';
  await page.click(buttonSelector);

  // Simulate hitting Enter key
  await page.keyboard.press("Enter");

  try {
    await page.waitForSelector('[data-testid="product-tile"]', {
      timeout: 5000,
    });
    const products = await page.evaluate(() => {
      const productCards = Array.from(
        document.querySelectorAll('[data-testid="product-tile"]')
      );
      const subProducts = productCards.slice(0, 10);
      return subProducts.map((card) => {
        const name =
          card.querySelector(".product__title")?.textContent || "N/A";
        const price = card.querySelector(".price")?.textContent || "N/A";

        const anchor = card.querySelector("a.product__link.product__image");

        const link = anchor
          ? `https://www.coles.com.au${anchor.getAttribute("href")}`
          : null;

        const imgSrc = card.querySelector('img[data-testid="product-image"]');

        const image = imgSrc ? imgSrc.getAttribute("src") : null;

        return { name, price, link, image };
      });
    });
    await browser.close();
    return products;
  } catch (error) {
    console.log("No such selector found.");
    await browser.close();
    return []; // Return an empty array if the selector is not found
  }
};

module.exports = {
  website_1,
};
