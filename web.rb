require 'sinatra'
require 'json'
set :public_folder, File.dirname(__FILE__) + '/assets'

get '/' do
  erb :start
end

post '/dataUpload/?' do
  raw = request.env["rack.input"].read
  #process raw data, return as JSON?
  { 
    :nodes => [
      {:name => "A", :group => 1},
      {:name => "B", :group => 1},
      {:name => "C", :group => 1},
      {:name => "D", :group => 2},
      {:name => "E", :group => 2}
    ],
    :links => [
      {:source => 1, :target => 0, :value => 1},
      {:source => 2, :target => 0, :value => 50},
      {:source => 3, :target => 2, :value => 2},
      {:source => 4, :target => 1, :value => 2},
      {:source => 1, :target => 4, :value => 2}
    ]
  }.to_json
end