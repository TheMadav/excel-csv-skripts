# Excel-Csv-Skripts

These are various scripts I use for very specific purposes. However, they should be adaptable to other purposes as well.

Feel free to use them for your Excel Sheets

## Import Holidays

Imports jewish holidays from Hebcal and matches them to two CSVs containing titles and IDs of holidays and parashot. The output is a csv file with date, name, prequel (e.g. "Erev"), sequel (e.g. "3rd Candle"), holiday\_id and parasha\_id.

## Import Kosherlist

Script to import the german kosherlist from a huge excel into a database via CSV-files. 

The Kosherlist consists of one Excel-file with multiple Worksheets. Each Worksheets represents a category and contains a number of products, including their producer and vendors (separated by ',').

The script creates
- one category-CSV (all categories + ID)
- one producer-CSV (all producers + ID)
- one vendor-CSV (all vendors + ID)
- one product_vendor-CSV (because of the m:n relationship)
- one product-CSV

## Import Prayertimes

A script to combine various Excels into two CSVs. The Excels contain prayer times for different cities in the same structure. 

The script reads all of them, produces one CSV with city-names and one with all prayer-times and a coresponding city\_id.