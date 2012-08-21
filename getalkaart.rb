require 'sinatra'
require 'haml'
require "sinatra/reloader" if development?

get '/' do
  @getalX = rand 1000
  @getalY = rand 1000
  @score = 10
  @total = 15
  haml :hello
end
