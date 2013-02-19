require 'sinatra'
require 'json'
require './classes.rb'
require './methods.rb'
set :environment, :development
set :public_folder, File.dirname(__FILE__) + '/assets'
set :logging, :true

get '/' do
  erb :start
end

post '/dataUpload/?' do
  nodes, links = [], []
  raw = request.env["rack.input"].read.split(/\r\n/)
  clean_input(raw)
  puts "-"*10
  raw.each_with_index { |x, i| puts "#{i}: #{x.inspect}" }
  puts "-"*10
  parse_input(nodes, links)
  
  nodes.each { |x| puts x.inspect }
  links.each { |x| puts x.inspect }
  
  { 
    :nodes => nodes,
    :links => links
  }.to_json
end