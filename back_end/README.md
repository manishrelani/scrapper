// 1.work on half name search 
// 2.like app or bnd 
// 3.make sure the result has exactly the same output or no output at all

i have two websites . I am scraping data from them. 
the website list grocery website

Website 1 : if i search apple 
i will get results as below
1.Coles Pink Lady Apples | approx 200g -price 20rs
2.Coles Pink Lady Apples 1kg | 1 each  -price 40rs
3.Coles Royal Gala Apples Loose | approx 160g -price 10rs
and soo on


when i scrape 2nd website i get result as below

1.Fresh Pink Lady Apples Each -price 30rs
2.Fresh Granny Smith Apples Each -price 60rs
3.Apple Royal Gala Each -price 80rs

now as you can see

Pink Lady Apples  and gala apple are the common form of apple on both the website but prices are different

i want to create a final list that has the common names from both the apples and there different prices.

how can i do this in node.js/express


  const final = [
    {
      title: "pink",
      discription: "sdsds",
      img: "sdsd",
      website_attributes: [{ price: "dsd", link: "ewe", website_name: "" }, {}],
    },
  ];

   impt  ->  string-similarity or fuzzyset.js