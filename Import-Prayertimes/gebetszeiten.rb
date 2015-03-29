#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'rubyXL'
require 'csv'
require 'date'
require 'time'

d = Date.today

CITYFIELDS = %w{CityID City }
CSVCITIES = CSV.open("cities#{d.year.to_s}.csv", 'wb' ,{:col_sep => ";", :force_quotes=>true})
CSVCITIES << CITYFIELDS

CSVPRAYERTIMES = %w{CityID Date Morgenr Teflin Sonnenaufgang SchmaAvraham SchmaGra TfilaAvraham TfilaGra Mittag PlagGra PlagAvraham Schabbat Sonnenuntergang Fasttag MozeiSchabbat MozeiTam}
CSVPRAYER = CSV.open("gebetszeiten#{d.year.to_s}.csv", 'wb' ,{:col_sep => ";", :force_quotes=>true})
CSVPRAYER << CSVPRAYERTIMES

def writeCSV(csv, dataArray)
  csv << dataArray
end

def calculateTime(datum,exceltime)
  
  if (exceltime.nil? || exceltime == " ")
    return ""
  end
  if exceltime.is_a?(Numeric) 
    seconds   = exceltime * 86400
    hour      = (seconds/3600).to_i
    if (hour>=24)
      hour    = hour-24
    end
    minutes   = ((seconds.modulo(3600))/60).to_i
    rubytime  = Time.new(2012,datum.month,datum.day, hour,minutes,0, "-01:00")
    return rubytime
  end

  hour = exceltime.strftime("%H")
  minutes = exceltime.strftime("%M")
  rubytime  = Time.new(2015,datum.month,datum.day, hour,minutes,0, "-01:00") 
  return rubytime
end

$index = 0
$cityArray = []
Dir.foreach("Städte#{d.year.to_s}/") do |item|
  next if !(File.extname(item) == ".xlsx")
  $index = $index + 1
  city = item.chomp(File.extname(item) )
  case city
    when "Duesseldorf"
      city = "Düsseldorf"
    when "Frankfurt"
      city = "Frankfurt am Main"
    when "Goettingen"
      city = "Göttingen"
    when "Koeln"
      city = "Köln"
    when "Luebeck"
      city = "Lübeck"
    when "Muenchen"
      city = "München"
    when "Muenster"
      city = "Münster"
    when "Nuernberg"
      city = "Nürnberg"
    when "Osnabrueck"
      city = "Osnabrück"
    when "Saarbruecken"
      city = "Saarbrücken"
    when "Wuerzburg"
      city = "Würzburg"
  end  
  $cityArray << [$index, city]
  puts "#{$index}: #{city}"
  
  # Comment out for testing (uses only Aachen)
 #next if ! (city == "Aachen")
  workbook = RubyXL::Parser.parse("Städte#{d.year.to_s}/#{item}")
  sheet = workbook.worksheets[0].extract_data
  $dataArray = []
  sheet.each do |row|
  
  if (['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'].include? row[0] )
    data = Hash.new
    datum = DateTime.strptime(row[1].to_s, "%d.%m.%y")
    data = {
      'city'              => $index,
      'Date'              => datum,
      'Morgenr'           => calculateTime(datum,row[2]),
      'Tefilin'           => calculateTime(datum,row[3]),
      'Sonnenaufgang'     => calculateTime(datum,row[4]),
      'SchmaAvraham'      => calculateTime(datum,row[5]),
      'SchmaGra'          => calculateTime(datum,row[6]),
      'TfilaAvraham'      => calculateTime(datum,row[7]),
      'TfilaGra'          => calculateTime(datum,row[8]),
      'Mittag'            => calculateTime(datum,row[9]),
      'PlagGra'           => calculateTime(datum,row[10]),
      'PlagAvraham'       => calculateTime(datum,row[11]),
      'Schabbat'          => calculateTime(datum,row[12]),
      'Sonnenuntergang'   => calculateTime(datum,row[13]),
      'Fasttag'           => calculateTime(datum,row[14]),
      'MozeiSchabbat'     =>calculateTime(datum, row[15]),
      'MozeiTam'          => calculateTime(datum,row[16]),
    }
     writeCSV(CSVPRAYER, data.values )
   end
   
end

end

$cityArray.each do |p|
  writeCSV(CSVCITIES, p )
end
