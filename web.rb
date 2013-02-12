require 'sinatra'
require 'json'
require './classes.rb'
set :environment, :development
set :public_folder, File.dirname(__FILE__) + '/assets'
set :logging, :true

get '/' do
  erb :start
end

post '/dataUpload/?' do
  nodes, links = [], []
  raw = request.env["rack.input"].read
  raw = raw.split(/\r\n/)
  raw.each do |line|
    if line.include? "show"
      nodes.push(Node.new(line.split(' ')[1], 0))
    end
  end

  { 
    :nodes => nodes,
    :links => links
  }.to_json
end