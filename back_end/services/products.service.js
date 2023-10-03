const { website_1 } = require("../scrappers/coles_grocery.scrapper");
const { website_2 } = require("../scrappers/wools_worth.scrapper");
const Fuse = require("fuse.js");

const fetchAllProducts = async (product_name) => {
  try {
    const wordsToRemove = ["Coles", "Woolworths", "each", "|"];
    const pattern = new RegExp(wordsToRemove.join("|"), "gi");

    // Use Promise.all to run website_1 and website_2 concurrently
    const [website1Data, website2Data] = await Promise.all([
      website_1(product_name),
      website_2(product_name),
    ]);

    const commonNames = [];
    for (const item1 of website1Data) {
      const exactMatch = website2Data.find(
        (item2) => item2.name === item1.name
      );

      if (exactMatch) {
        const commonName = determineCommonName(item1, exactMatch);
        commonNames.push({
          websites: [item1, exactMatch],
          commonName: commonName,
        });
      } else {
        const sanatizedItem1 = item1.name.replace(pattern, "");
        // If there's no exact match, try fuzzy matching
        const sanatizedWebsite2 = website2Data.map((item2) => {
          item2.name.replace(pattern, "");
          return item2;
        });
        const fuzzyMatch = findFuzzyMatch(sanatizedItem1, sanatizedWebsite2);

        const commonName = determineCommonName(item1, fuzzyMatch);
        if (fuzzyMatch) {
          if (
            item1.name.toLocaleLowerCase().includes("kg") ||
            fuzzyMatch.name.toLocaleLowerCase().includes("kg")
          ) {
            if (
              item1.name.toLocaleLowerCase().includes("kg") &&
              fuzzyMatch.name.toLocaleLowerCase().includes("kg")
            ) {
              commonNames.push({
                websites: [item1, fuzzyMatch],

                commonName: commonName,
              });
            } else {
              commonNames.push({
                websites: [item1],

                commonName: commonName,
              });
              commonNames.push({
                websites: [fuzzyMatch],

                commonName: commonName,
              });
            }
          } else {
            commonNames.push({
              websites: [item1, fuzzyMatch],

              commonName: commonName,
            });
          }
        } else {
          commonNames.push({
            websites: [item1],

            commonName: commonName,
          });
        }
      }
    }
    commonNames.sort((a, b) => b.websites.length - a.websites.length);
    return commonNames;
  } catch (error) {
    console.log("error1", error);
    return error;
  }
};

function findFuzzyMatch(name, dataset) {
  const options = {
    keys: ["name"],
    threshold: 0.5,
  };

  const fuse = new Fuse(dataset, options);
  const result = fuse.search(name);

  if (result.length > 0) {
    return result[0].item;
  }

  return null;
}
function determineCommonName(item1, item2) {
  // Remove the website names "Coles" and "Woolworths" from the names
  const name1WithoutBrand = item1.name.replace(/Coles|Woolworths/gi, "").trim();
  const name2WithoutBrand = item2?.name
    .replace(/Coles|Woolworths/gi, "")
    .trim();

  // Remove units like "2kg", "1 kg", "kg", "6x250ml", etc.
  const name1WithoutUnits = name1WithoutBrand
    .replace(/\d+(\.\d+)?(kg|g|ml|x\d+)?/gi, "")
    .trim();
  const name2WithoutUnits = name2WithoutBrand
    ?.replace(/\d+(\.\d+)?(kg|g|ml|x\d+)?/gi, "")
    .trim();
  if (!item2) {
    return name1WithoutUnits;
  }
  // Split the names into words
  const words1 = name1WithoutUnits.split(/\s+/);

  const words2 = name2WithoutUnits?.split(/\s+/);

  // Find common words between the two names
  const commonWords = words1.filter((word1) => words2?.includes(word1));

  // Combine the common words to create the common name
  const commonName = commonWords.join(" ");

  return commonName;
}
module.exports = {
  fetchAllProducts,
};
