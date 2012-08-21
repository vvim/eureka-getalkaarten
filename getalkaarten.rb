require 'sinatra'
require 'haml'
require 'data_mapper'  
require "sinatra/reloader" if development?

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
  if defined? @vragen.first
    @vraag = @vragen.first
  else
      # 1. vraag aanmaken:
      @vraag = Vraag.new
      @vraag.getalX = rand 1000
      @vraag.getalY = rand 1000
      @vraag.operator = "+"
      @vraag.created_at = Time.now  
      @vraag.updated_at = Time.now  
      # 2. vraag in de databank steken (om te kunnen vergelijken als er een antw is gegeven
      @vraag.save  
  end

  
  # 3. score bijhouden:
  @score = 10
  @total = 15
  
  # 4. verstreken tijd bijhouden??? (nog niet opgelost)
  haml :getalkaartenvraag
end


post '/antwoord' do
  antwoord = params[:antwoord]
  "Het antwoord is: #{antwoord}"
end  

get '/antwoord' do
  "No Post today"
end



#################### test
get '/test' do
  # <p style="color: red; font-weight: bold">dit is een testpagina en dient verwijderd te worden!!</p>
  @vragen = Vraag.all :order => :id.asc
  erb :toonvragen
end

get '/destroy' do
  # <p style="color: red; font-weight: bold">dit is een testpagina en dient verwijderd te worden!!</p>
  Vraag.all.destroy

  # 1. vraag aanmaken om crash te vermijden:
  @vraag = Vraag.new
  @vraag.getalX = rand 1000
  @vraag.getalY = rand 1000
  @vraag.operator = "+"
  @vraag.created_at = Time.now  
  @vraag.updated_at = Time.now  
  # 2. vraag in de databank steken (om te kunnen vergelijken als er een antw is gegeven
  @vraag.save  

  erb :toonvragen
end
