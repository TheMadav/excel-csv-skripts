require 'CSV'
require 'date'
require 'pp'
require 'time'

def read_csv (file, origin)
  if origin == "SK"
    return CSV.read( file, headers:true, col_sep:";", encoding: 'ISO-8859-1' )
  else
    return CSV.parse(File.readlines(file).drop(7).join.force_encoding('iso-8859-1').encode('utf-8'), headers:true, col_sep:";", encoding: 'ISO-8859-1')
  end
end

def write_csv (data, origin)
  CSV.open("#{File.dirname(__FILE__)}/ynab_import_#{origin}_#{DateTime.now.strftime('%Y-%m-%d')}.csv", 'w') do |csv|
    csv << ["Date","Payee","Category","Memo","Outflow","Inflow"]
    data.each do |j|
      csv << j
    end
  end
end

def define_origin file_name
  origin = "SK"
  if file_name.include? "___"
    origin = "DKB"
  end
  return origin
end

def format_data (input_date)
  d = Date.strptime(input_date, '%d.%m.%y')
  return d.strftime("%d/%m/%Y")
end
input_file = ARGV[0]

if (input_file.nil? ||! File.exists?(input_file) )
  puts "Angegebene Datei existiert nicht"
  exit
end

def format_SK_Auszug (input_data)
  output_data = Array.new
  input_data.each do |row|
   #Date,Payee,Category,Memo,Outflow,Inflow
     output_entry = Array.new
     output_entry << format_data(row["Valutadatum"])
     output_entry << row["Beguenstigter/Zahlungspflichtiger"]
     output_entry  << ""
     output_entry  << row["Verwendungszweck"]
     output_entry << (row["Betrag"].to_f * -1)
     output_data << output_entry
  end
  return output_data
  
end

def format_DKB_Auszug (input_data)
  output_data = Array.new
  input_data.each do |row|
   #Date,Payee,Category,Memo,Outflow,Inflow
     output_entry = Array.new
     output_entry << format_data(row["Wertstellung"])
     output_entry << row["Umsatzbeschreibung"]
     output_entry  << ""
     output_entry  << ""
     output_entry << (row["Betrag (EUR)"].to_f * -1)
     output_data << output_entry
  end
  return output_data 
end

origin = define_origin input_file
input_data = read_csv( input_file, origin)
if origin == "SK"
  output_data = format_SK_Auszug(input_data)
else
  output_data = format_DKB_Auszug(input_data)
end

write_csv(output_data, origin)

