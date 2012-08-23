require 'sinatra'
require 'haml'
require 'data_mapper'  
require "sinatra/reloader" if development?

def willekeurigHondertal()
  # genereert een willekeurig honderdtal
  # geeft rand(10) een getal tussen 0 en 9?? dan kan dit dus ook 99 geven??? -> honderdtal : "rand(9) + 1"
  v = ((((rand(9) + 1) * 10) + rand(10)) * 10) + rand(10)
  return v
end

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/vragen.db")  

class Vraag
  include DataMapper::Resource  
  property :id, Serial  
  property :getalX, Integer, :required => true  
  property :operator, Text, :required => true  # +, -, *, /
  property :getalY, Integer, :required => true
  #eventueel ook moeilijkheidsgraag bijhouden???      
  #property :complete, Boolean, :required => true, :default => false  
  property :created_at, DateTime  
  property :updated_at, DateTime  

  # method aan toevoegen die een nieuwe vraag aanmaakt?
  def nieuweVraag()
      v = Vraag.new
      v.getalX = willekeurigHondertal
      v.getalY = willekeurigHondertal
      v.operator = "+"
      v.created_at = Time.now  
      v.updated_at = Time.now
      return v
  end
end  

class Antwoord
  include DataMapper::Resource  
  property :id, Serial
  property :gegeven_antwoord_str, Text
  property :id_vraag, Integer
  #Vraag vraag
end

#class Score
#  include DataMapper::Resource  
#  property :score, Integer, :required => true  
#  property :total, Integer, :required => true
#  property :created_at, DateTime  
#  property :updated_at, DateTime  
#end  
#
# globale variable?  score = Score.new

  
DataMapper.finalize.auto_upgrade!  


get '/' do
  #bij het laden van de pagina:
  # 1. vraag aanmaken (eventueel kijken of er nog een openstaande vraag staat???)
  # 2. vraag in de databank steken (om te kunnen vergelijken als er een antw is gegeven
  # 3. score bijhouden!
  # 4. verstreken tijd bijhouden?
  
  # 0. bestaat er al een vraag?? moeilijkheid: is die open vraag wel binnen de moeilijkheidsgraad???
  #       defined? @vraag
  @vragen = Vraag.all :order => :id.desc
  if @vragen.first.nil?
    # "vragen.first is NIL en is dus leeg, er is nog geen vraag gesteld", zelfs als er nog geen 'vragen.db' bestaat
      # 1. vraag aanmaken:
      @vraag = Vraag.new
      @vraag.getalX = willekeurigHondertal
      @vraag.getalY = willekeurigHondertal
      @vraag.operator = "+"
      @vraag.created_at = Time.now  
      @vraag.updated_at = Time.now  
      # 2. vraag in de databank steken (om te kunnen vergelijken als er een antw is gegeven
      @vraag.save  
  else
    @vraag = @vragen.first
  end

  
  # 3. score bijhouden:
  @score = 10
  @total = 15
  
  # 4. verstreken tijd bijhouden??? (nog niet opgelost)
  haml :getalkaartenvraag
end


post '/antwoord' do
  # 1. is er wel een vraag gesteld?
  # 2. is het het juiste antwoord?
  # 3. is het een denkfou

  # een onbestaande parameter is WEL gedefinieerd maar is NIL
  # onbestaande paramets zijn NIET gedefinieerd en hebben dus zelfs geen NIL waarden (testen op joris.nil? geeft crash)
  antwoord = params[:antwoord]

  @vragen = Vraag.all :order => :id.desc
  if @vragen.first.nil?
    # "vragen.first is NIL en is dus leeg, er is nog geen vraag gesteld"
    # hoe kan dat nu? gebruiker heeft een antwoord gepost maar geen vraag gesteld? lijkt mij straf
    # programmeerfout of misbruik
    "straf, ge hebt een antwoord gepost, maar er is geen vraag gesteld geweest. En wat nu? redirect / of /nieuwe vraag misschien?"
  else
    # er is dus een vraag gesteld en op deze vraag is een antwoord gegeven, de normale gang van zaken
    @vraag = @vragen.first
    "Het antwoord is: #{escape_html antwoord}, komt dat overeen met #{escape_html @vraag.getalX} #{escape_html @vraag.operator} #{escape_html @vraag.getalY} = #{escape_html(@vraag.getalX + @vraag.getalY)}  ?"
  end


end  

get '/antwoord' do
  # als het geen POST is maar een GET (dus geen formulier ingevuld, maar gewoon gesurft naar /antwoord)
  # dan best de mensen doorverwijzen naar de hoofdpagina:
  redirect '/'
end

get '/nieuwevraag' do
  
  # 1. nieuwe vraag aanmaken om crash te vermijden:
  @vraag = Vraag.new
  @vraag.getalX = willekeurigHondertal
  @vraag.getalY = willekeurigHondertal
  @vraag.operator = "+"
  @vraag.created_at = Time.now  
  @vraag.updated_at = Time.now  
  # 2. vraag in de databank steken (om te kunnen vergelijken als er een antw is gegeven
  @vraag.save  

  redirect '/'
end



#################### toonvragen
# testpagina, verwijderen!!!!
get '/toonvragen' do
  # <p style="color: red; font-weight: bold">dit is een testpagina en dient verwijderd te worden!!</p>
  @vragen = Vraag.all :order => :id.asc
  erb :toonvragen
end

# testpagina, verwijderen!!!!
get '/destroy' do
  # <p style="color: red; font-weight: bold">dit is een testpagina en dient verwijderd te worden!!</p>
  Vraag.all.destroy

  erb :toonvragen
end







# testpagina, verwijderen!!!!
get '/profanity' do
#lege vragen.db, testen of @vragen.first een NIL geeft!!!! @vragen.first.nil?

  @vragen = Vraag.all :order => :id.desc
  
  if @vragen.first.nil?
    "vragen.first is NIL en is dus leeg, er is nog geen vraag gesteld"
  else
    "vragen.first is GEEN en bestaat dus al???"
  end

end
