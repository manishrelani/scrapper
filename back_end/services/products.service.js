const { website_1 } = require("../scrappers/coles_grocery.scrapper");
const { website_2 } = require("../scrappers/wools_worth.scrapper");
const Fuse = require("fuse.js");

const fetchAllProducts = async (product_name) => {
  try {
    const wordsToRemove = [
      "Coles",
      "Woolworths",
      "each",
      "\\|",
      "approx",
      "loose",
      "Loose",
      "fresh",
      "Fresh",
      "200g",
      "Each",
    ];
    const pattern = new RegExp(
      "\\b(" +
        wordsToRemove
          .map(
            (word) =>
              word
                .replace(/\b\w*\d\w*\b/g, "")
                // Remove numbers and adjacent characters without space
                .replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&") // Escape special characters
          )
          .join("|") +
        ")\\b",
      "gi"
    );

    // Use Promise.all to run website_1 and website_2 concurrently
    const [website1Data, website2Data] = await Promise.all([
      website_1(product_name),
      website_2(product_name),
    ]);

    const copiedArray = [...website1Data];

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
        const sanitizedItem1 = {
          ...item1,
          name: item1.name
            .replace(pattern, "")
            .replace(/\b\w*\d\w*\b/g, "")
            .replace(/\|/g, "")
            .trim(),
        };

        // If there's no exact match, try fuzzy matching
        const sanitizedWebsite2 = website2Data.map((item2) => {
          // Create a new object with the same properties as item2
          const newItem2 = { ...item2 };

          // Use the result of replace to update the 'name' property in the new object
          newItem2.name = item2.name
            .replace(pattern, "")
            .replace(/\b\w*\d\w*\b/g, "")
            .replace(/\|/g, "")
            .trim();

          return newItem2;
        });

        const { position, fuzzyMatch } = findFuzzyMatch(
          sanitizedItem1.name,
          sanitizedWebsite2
        );

        const commonName = determineCommonName(item1, fuzzyMatch);
        if (fuzzyMatch) {
          if (
            item1.name.toLowerCase().includes("kg") ||
            website2Data[position].name.toLowerCase().includes("kg")
          ) {
            if (
              item1.name.toLowerCase().includes("kg") &&
              website2Data[position].name.toLowerCase().includes("kg")
            ) {
              commonNames.push({
                websites: [item1, website2Data[position]],
                commonName: commonName,
              });

              removeMatchedItem(
                copiedArray,
                website2Data,
                item1,
                website2Data[position]
              );
            }
          } else {
            commonNames.push({
              websites: [item1, website2Data[position]],

              commonName: commonName,
            });
            removeMatchedItem(
              copiedArray,
              website2Data,
              item1,
              website2Data[position]
            );
          }
        }
      }
    }
    for (item of [...copiedArray, ...website2Data]) {
      const commonName = determineCommonName(item);

      commonNames.push({
        websites: [item],
        commonName: commonName,
      });
    }
    commonNames.sort((a, b) => b.websites.length - a.websites.length);
    return commonNames;
  } catch (error) {
    console.log("error in products api", error);
    return error;
  }
};

function findFuzzyMatch(web1, dataset) {
  const options = {
    keys: ["name"],
    threshold: 0.5,
    location: 1,
    minMatchCharLength: 2,
    // findAllMatches: true,
    // ignoreLocation: true,
  };

  const fuse = new Fuse(dataset, options);
  const result = fuse.search(web1);

  // result.sort((a, b) => a.refIndex - b.refIndex);
  if (result.length > 0) {
    const position = dataset.indexOf(result[0].item);
    return { position: position, fuzzyMatch: result[0].item };
  }

  return { position: null, fuzzyMatch: null };
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
  if (!commonName) {
    const oneWebsiteName = name1WithoutUnits
      ? name1WithoutUnits
      : name2WithoutUnits;
    return oneWebsiteName;
  }
  return commonName;
}
function removeMatchedItem(copiedArray, website2Data, item1, fuzzyMatch) {
  const index1 = copiedArray.indexOf(item1);
  // Replace with the item you want to remove
  const index2 = website2Data.indexOf(fuzzyMatch);
  if (index1 !== -1) {
    copiedArray.splice(index1, 1);
  }
  if (index2 !== -1) {
    website2Data.splice(index2, 1);
  }
}
module.exports = {
  fetchAllProducts,
};
