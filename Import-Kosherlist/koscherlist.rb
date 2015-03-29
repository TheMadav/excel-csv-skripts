#!/usr/bin/env ruby

require 'rubygems'
require 'spreadsheet'
require 'csv'


FIELDSPRODUCT = %w{ProductID Product HerstellerID Milchig LeMahedrin KategorieID }
FIELDSCAT = %w{KategorieID KategorieName }
FIELDSPRODUCER = %w{ProductID ProducerName }
FIELDSVENDOR = %w{VendorID VendorName }
FIELDSPRODUCTVENDOR = %w{ProductID VendorID }

CSVPRODUCTS = CSV.open('koscherlist.csv', 'wb' ,{:col_sep => ";", :force_quotes=>true})
CSVPRODUCTS << FIELDSPRODUCT

CSVCATEGORY = CSV.open('koscherlist_kategory.csv', 'wb' ,{:col_sep => ";", :force_quotes=>true})
CSVCATEGORY << FIELDSCAT

CSVPRODUCER = CSV.open('koscherlist_producer.csv', 'wb' ,{:col_sep => ";", :force_quotes=>true})
CSVPRODUCER << FIELDSPRODUCER

CSVVENDOR = CSV.open('koscherlist_vendors.csv', 'wb' ,{:col_sep => ";", :force_quotes=>true})
CSVVENDOR << FIELDSVENDOR

CSVPRODUCTVENDOR = CSV.open('koscherlist_product_vendors.csv', 'wb' ,{:col_sep => ";", :force_quotes=>true})
CSVPRODUCTVENDOR << FIELDSPRODUCTVENDOR

def writeCSV(csv, dataArray)
  csv << dataArray
end

def getProduct(row)
  product = Hash.new
  product = {"producer" => row[0], "milk" => row[1], "lemehadrin" => row[2], "productName" => row[3], "vendors" => row[4]}
  return product
end

def checkListForProducer(product, producerID)
  if ( ! product["producer"] .nil? && ! $producers.any?{ |b| b["producerName"] == product["producer"] }  )
    producer = {"id" => producerID, "producerName" =>product["producer"]}
    $producers << producer
  end
  searchedProducer = $producers.select{|b| b["producerName"] == product["producer"]}
      
  if (! searchedProducer.nil? && ! searchedProducer[0].nil? )
    return searchedProducer[0]["id"]        
  end
end

book = Spreadsheet.open('Koscherliste_mac.xls') 
sheets = book.worksheets
sheets.slice!(0)

catID       = 0
productID   = 0
vendorID    = 0
producerID  = 0
productID   = 0
$producers  = []
$vendors    = []
$products   = []
$categories = []
$productVendors = []


sheets.each do |sheet|

  puts "<---starting Sheet "+sheet.name+"--->"
  catID = catID +1
  category = Hash.new
  category["name"] = sheet.name
  category["id"] = catID
  $categories << category
  
  sheet.each do |row|
    product = getProduct(row)
    producerID = producerID + 1
    product["producerID"] = checkListForProducer(product, producerID)
    product["categoryID"] = category["id"]
    
    if (! product["productName"].nil?)
        productID = productID +1
        productForCSV = {"productID" => productID, "productName" => product["productName"], "producerID" => product["producerID"], "milk"  =>product["milk"], "LeMahedrin"  =>product["lemehadrin"], "KategorieID" => category["id"]}
        $products << productForCSV
    end
        
    if (! product["vendors"].nil?)
        
      vendorsExplode = product["vendors"].split(",")
      vendorsExplode.each do |singleVendor|
              
        if ( ! $vendors.any?{ |b| b["vendorName"] == singleVendor }  )
          vendorID = vendorID + 1
          vendor = {"id" => vendorID, "vendorName" => singleVendor}
          $vendors << vendor
        end
             
         searchedVendor = $vendors.select{|b| b["vendorName"] == singleVendor}
        
         if (! searchedVendor.nil? && ! searchedVendor[0].nil? )
             productVendorID = searchedVendor[0]["id"]        
         end
        
         $productVendors << {"product" => productID, "vendor" => productVendorID}
        end
          
          
      end 
    end 
  end

puts "<--- Excel ausgewertet-->"

puts "<--- Beginne CSV Dateien zu schreiben-->"
puts "<-- Schreibe Hersteller-->"

$producers.each do |p|
  writeCSV(CSVPRODUCER, p.values )
end

puts "<-- Schreibe Haendler-->"
$vendors.each do |p|
  writeCSV(CSVVENDOR, p.values )
end
puts "<--Schreibe Produkte -->"
$products.each do |p|
  writeCSV(CSVPRODUCTS, p.values )
end
puts "<-- Schreibe Kategorien -->"
$categories.each do |p|
  writeCSV(CSVCATEGORY, p.values )
end
puts "<-- Schreibe Haendler <-> Produkte Beziehung -->"
$productVendors.each do |p|
  writeCSV(CSVPRODUCTVENDOR, p.values )
end

puts "<---- Fertig ---->"