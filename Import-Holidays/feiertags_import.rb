require 'CSV'
require 'date'
require 'pp'
require 'time'
require 'json'
 require 'net/http'

def read_csv (file)
  return CSV.read( file, headers:true, col_sep:",", encoding: 'ISO-8859-1' )
end


def output_csv(data, year)
  CSV.open("#{File.dirname(__FILE__)}/import_into_feiertage-#{year}.csv", 'w') do |csv|
    #csv << ["date","name","prequel","sequel","holiday_id","parascha_id"]
    csv << data.first.keys 
    data.each do |j|
      csv << j.values
      end
  end
end

def format_name(nameImport)
  nameFormated = Hash.new("")
  return nameFormated unless (! nameImport.nil?)
  
  # Rename english holidays to german ones
  nameImport.gsub!(/Sh/, 'Sch')
  nameImport.gsub!(/sh/, 'sch')
  nameImport.gsub!(/Yom/, 'Jom')
  nameImport.gsub!(/Pesach/, 'Pessach')
  nameImport.gsub!(/Chanukah/, 'Hannuka')
  nameImport.gsub!(/ Candles/, '. Kerze')
  nameImport.gsub!(/ Candle/, '. Kerze')
  nameImport.gsub!(/Tisch\'a/, 'Tischa')
  nameImport.gsub!(/Tu BiSchvat/, 'Tu BiSchwat')
  nameImport.gsub!(/Sch'vat'/, 'Schwat')   
  nameImport.gsub!(/Yeruschalayim/, 'Jeruschalayim')   
  
  if nameImport.include? "Erev"
    nameFormated['prequel'] = "Erev"
    nameImport.gsub!(/Erev /, '')
  end
  
  nameFormated['name'] = nameImport
  
  if nameImport.include? "Rosch Chodesch"
    temp = nameImport.split
    nameFormated['name']    = "#{temp[0]} #{temp[1]}" 
    nameFormated['sequel']  = temp[2] 
  end
  if nameImport.include? "Rosch Haschana"
    temp = nameImport.split
    nameFormated['name']    = "#{temp[0]} #{temp[1]}" 
    nameFormated['sequel']  = temp[2] 
  end
  if nameImport.include? "Paraschat"
    temp = nameImport.split
    nameFormated['name']    = "Schabbat" 
    nameFormated['sequel']  = rename_parascha(nameImport.gsub!(/Paraschat/, '').strip!)
  end
  if nameImport.include? "Sukkot"
    temp = nameImport.split
    nameFormated['name']    = temp[0]
    nameFormated['sequel']  = "#{temp[1]} #{temp[2]}" 
  end
  
  if nameImport.include? "Pessach"
    temp = nameImport.split
    nameFormated['name']    = temp[0]
    nameFormated['sequel']  = "#{temp[1]} #{temp[2]}" 
  end
  
  if nameImport.include? "Hannuka"
    temp = nameImport.split
    nameFormated['name']    = temp[0][0..-2]
    nameFormated['sequel']  = "#{temp[1]} #{temp[2]}" 
  end

  return nameFormated

end

def load_paraschot  
  paraschot = Array.new
  paraschotImport = File.readlines( "paraschot.csv")#, headers:false, col_sep:",", encoding: 'UTF-8' )
  paraschotImport.each do |row|
    tmp = row.gsub!(/"/, "").split(";")
    parascha = Hash.new()

    parascha["parascha_id"] =  tmp[0]
    parascha["name"] =  tmp[1].strip
    paraschot << parascha
  end
  return paraschot
end

def load_feiertage  
  feiertage = Array.new
  feiertageImport = File.readlines( "feiertage.csv")#, headers:false, col_sep:",", encoding: 'UTF-8' )
  feiertageImport.each do |row|
    tmp = row.gsub!(/"/, "").split(";")
    feiertag = Hash.new()

    feiertag["feiertag_id"] =  tmp[0]
    feiertag["name"] =  tmp[1].strip
    feiertage << feiertag
  end
  return feiertage
end
def rename_parascha (schabbatParascha)
  
  schabbatParascha.gsub!(/Schemot/, 'Sch‘mot')
  schabbatParascha.gsub!(/Vaera/, 'WaEra')
  schabbatParascha.gsub!(/Beschalach/, 'BeSchalach')
  schabbatParascha.gsub!(/Terumah/, 'Trumah')
  schabbatParascha.gsub!(/Tetzaveh/, 'Tezaweh')
  schabbatParascha.gsub!(/Ki Tisa/, 'Ki Teze')
  schabbatParascha.gsub!(/Vayakhel/, 'WaJak‘hel')
  schabbatParascha.gsub!(/Tazria/, 'Tasria')
  schabbatParascha.gsub!(/Tzav/, 'Zaw')
  schabbatParascha.gsub!(/Schmini/, 'Sch‘mini')
  schabbatParascha.gsub!(/Miketz/, 'Mikez')
  schabbatParascha.gsub!(/Vayeschev/, 'WaJeschew')
  schabbatParascha.gsub!(/Vayetzei/, 'WaJeze')
  schabbatParascha.gsub!(/Chayei Sara/, 'Chaje Sarah')
  schabbatParascha.gsub!(/Yitro/, 'Jitro')
  schabbatParascha.gsub!(/Tavo/, 'Tawo')
  schabbatParascha.gsub!(/Teitzei/, 'Teze')
  schabbatParascha.gsub!(/Nitzavim/, 'Nizawim')
  schabbatParascha.gsub!(/Bamidbar/, 'BeMidbar')
  schabbatParascha.gsub!(/Achrei Mot/, 'Acharei Mot')
  schabbatParascha.gsub!(/Kedoschim/, 'Kedoschim')
  schabbatParascha.gsub!(/Vayechi/, 'WaJechi')
  schabbatParascha.gsub!(/Vayikra/, 'WaJikra')
  schabbatParascha.gsub!(/Beha'alotcha/, 'BeHa’alot‘cha')
  schabbatParascha.gsub!(/Sch'lach/, 'Sch’lach Lecha')
  schabbatParascha.gsub!(/Devarim/, 'D‘warim')
  schabbatParascha.gsub!(/Lech-Lecha/, 'Lech Lecha')
  schabbatParascha.gsub!(/Re'eh/, 'Reeh')
  schabbatParascha.gsub!(/Vayeilech/, 'WaJelech')
  schabbatParascha.gsub!(/Ha'Azinu/, 'HaAsinu')
  schabbatParascha.gsub!(/Vayera/, 'WaJera')
  schabbatParascha.gsub!(/Vayechi/, 'WaJechi')
  schabbatParascha.gsub!(/Vayigasch/, 'WaJigasch')
  schabbatParascha.gsub!(/Eikev/, 'Ekew')
  schabbatParascha.gsub!(/Vayischlach/, 'WaJischlach')
  schabbatParascha.gsub!(/Vaetchanan/, 'WaEtchanan')
  schabbatParascha.gsub!(/Masei/, 'Mass‘ei')
 
  return schabbatParascha

end

def match_parascha(inputParaschot, paraschotArray)
  splitParascha = inputParaschot.split('-')
  paraschaIDs = Array.new
  splitParascha.each do |schabbatParascha|
    
    
    paraschotArray.each do|parascha|
      if parascha["name"].downcase.start_with? (schabbatParascha.downcase)
        paraschaIDs << parascha['parascha_id']
      end
    end

  end
  
  return paraschaIDs.join(";")
end

def match_feiertag(inputFeiertag, feiertageArray)
  feiertageArray.each do|feiertag|
    if feiertag["name"] == inputFeiertag
      puts "#{inputFeiertag} - #{feiertag['feiertag_id']}"
      return feiertag['feiertag_id'] 
    end
  end
  return ""
end

def create_feiertage_array(feiertageImport)
  feiertageExport = Array.new
  
  paraschotArray = load_paraschot
  feiertageArray = load_feiertage
  
  feiertageImport.each do |row|
  
    feiertag = Hash.new
    nameFormated = format_name( row['title'] )
    
    feiertag['prequel']       = nameFormated['prequel']
    feiertag['sequel']        = nameFormated['sequel']
    feiertag['name']          = nameFormated['name']
    feiertag['date']          = row['date']
  
    if feiertag['name'].include? "Schabbat"
      feiertag['parascha_id']   = match_parascha(feiertag['sequel'], paraschotArray)
      feiertag['holiday_id']    = match_feiertag(feiertag['name'], feiertageArray)
      feiertag['sequel']        = nil
    else
      feiertag['parascha_id']= nil
      feiertag['holiday_id']= match_feiertag(feiertag['name'], feiertageArray)    
    end

    feiertageExport << feiertag

  end
  
  return feiertageExport

end

year = ARGV[0]

if (year.nil?)
  puts "Ein Jahr muss angegeben werden"
  exit
end

years = year.split(",")

feiertageExport = Array.new

years.each do |year|
  source = "http://www.hebcal.com/hebcal/?v=1&cfg=json&maj=on&min=on&mod=on&nx=on&s=on&year=#{year}&month=x&mf=on&"
  resp = Net::HTTP.get_response(URI.parse(source))
  data = resp.body
  json = JSON.parse(data)
  feiertageImport = json['items']
  feiertageExport += create_feiertage_array(feiertageImport)
end

output_csv(feiertageExport, "#{years[0]}-#{years.last}")


