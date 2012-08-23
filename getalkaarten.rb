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
  
  # filmpje spelen? deze code toevoegen. In .haml kan je nog "&autoplay=1" toevoegen
  # om het filmpje automatisch te laten starten als de pagina geladen is
  @youtube = "dFI8vsdhIk8"

  # 4. verstreken tijd bijhouden??? (nog niet opgelost)
  haml :getalkaartenvraag
end


post '/antwoord' do
  # 1. is er wel een vraag gesteld?
  # 2. is het het juiste antwoord?
  # 3. is het een denkfout

  # 0a. is er wel een antwoord gegeven?
  # een onbestaande parameter is WEL gedefinieerd maar is NIL
  # onbestaande paramets zijn NIET gedefinieerd en hebben dus zelfs geen NIL waarden (testen op joris.nil? geeft crash)
  if not defined? params[:antwoord]
    # geen antwoord gegeven via het formulier
    # mag in principe niet voorkomen, maar dit zou een programmeerfout kunnen zijn of misbruik
    redirect '/misbruik/ANTWOORD-parameter-antwoord-is-niet-gedefinieerd'
  end

  # 0b. antwoord omzetten naar een getal
  # een parameter is altijd een String, dus we moeten hem eerst omzetten
  # naar een getal met Integer() vooraleer we er mee kunnen optellen/aftrekken/vermenigvuldigen/delen
  #antwoord = Integer(params[:antwoord])
  antwoord = params[:antwoord].to_i

  if not antwoord.is_a? Integer
    redirect "/misbruik/#{antwoord} is GEEN Integer"
  end



  @vragen = Vraag.all :order => :id.desc
  if @vragen.first.nil?
    # "vragen.first is NIL en is dus leeg, er is nog geen vraag gesteld"
    # hoe kan dat nu? gebruiker heeft een antwoord gepost maar geen vraag gesteld? lijkt mij straf
    # programmeerfout of misbruik
    "GEEN INTEGER straf, ge hebt een antwoord gepost, maar er is geen vraag gesteld geweest. En wat nu? redirect / of /nieuwe vraag misschien?"
    redirect '/misbruik/ANTWOORD-antwoord-gepost-maar-geen-vraag-gevonde-wat-nu-redirect?'
  else
    # er is dus een vraag gesteld en op deze vraag is een antwoord gegeven, de normale gang van zaken
    @vraag = @vragen.first
    "Het antwoord is: #{escape_html antwoord}, komt dat overeen met<br />#{escape_html @vraag.getalX} #{escape_html @vraag.operator} #{escape_html @vraag.getalY} = <b>#{escape_html(@vraag.getalX + @vraag.getalY)}</b>?"
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
get '/misbruik/:id' do
  "#{escape_html params[:id]}"
end





# testpagina, verwijderen!!!!
get '/dragdrop' do
#drag - drop test
  erb :dragdrop
end


# drag and drop:
####   http://www.brainjar.com/dhtml/drag/
####   http://www.dhtmlgoodies.com/index.html?page=dragDrop
####   AWESOME:  http://www.dhtmlgoodies.com/index.html?whichScript=drag-drop-nodes-quiz

