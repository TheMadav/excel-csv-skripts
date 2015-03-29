require 'CSV'
require 'date'
require 'pp'
require 'time'

def read_csv (file)
  return CSV.read( file, headers:true, col_sep:";", encoding: 'ISO-8859-1' )
end

def write_csv (data)
  CSV.open("#{File.dirname(__FILE__)}/ynab_import_#{DateTime.now.strftime('%Y-%m-%d')}.csv", 'w') do |csv|
    csv << ["Date","Payee","Category","Memo","Outflow","Inflow"]
    data.each do |j|
      csv << j
    end
  end
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
input_data = read_csv input_file

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

write_csv(output_data)



