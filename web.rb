require 'sinatra'
require 'json'
require 'fileutils'
require 'find'
require './classes.rb'
require './methods.rb'
set :environment, :development
set :public_folder, File.dirname(__FILE__) + '/assets'
set :logging, :true

get '/' do
  erb :start
end

put '/upload' do
  Dir.mkdir('uploads') unless File.exists?('uploads')
  File.open('uploads/' + env['HTTP_X_FILENAME'], "w") do |f|
    f.write(request.body.read)
  end
end

get '/processFiles' do
  nodes, links = [], []
  lgil_file = File.open('uploads/' + 'intervention.lgil', "r").read.split(/\r\n/)
  clean_lgil(lgil_file)
  parse_lgil(nodes, links)
  FileUtils.rm_rf('uploads')
  # @raw.each_with_index { |x, i| puts "#{i}: #{x}" }
  nodes.each { |x| puts x.inspect }
  links.each { |x| puts x.inspect }
  { 
    :nodes => nodes,
    :links => links
  }.to_json
end