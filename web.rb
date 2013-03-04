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
  if env['HTTP_X_FILENAME'] =~ /.+.lgil/
    File.open('uploads/intervention.lgil', "w") do |f|
      f.write(request.body.read)
    end
  else
    File.open('uploads/' + env['HTTP_X_FILENAME'], "w") do |f|
      f.write(request.body.read)
    end
  end
end

get '/processFiles' do
  #this needs to definitely wait for all the files to upload!
  #also needs to clear the previous contents
  nodes, links = [], []
  lgil_file = File.open('uploads/' + 'intervention.lgil', "r").read.split(/\r\n/) #somethings going on here!
  clean_lgil(lgil_file)
  create_nodes(nodes, links)
  parse_lgil
  parse_xml
  # # @raw.each_with_index { |x, i| puts "#{i}: #{x}" }
  # nodes.each { |x| puts x.inspect }
  # links.each { |x| puts x.inspect }
  FileUtils.rm_rf('uploads/.')
  { 
    :nodes => nodes,
    :links => links
  }.to_json
end