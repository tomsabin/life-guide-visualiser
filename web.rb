require 'sinatra'
require 'json'

get '/' do
  erb :start
end

post '/dataUpload/?' do
  raw = request.env["rack.input"].read
  #process raw data, return as JSON?
end