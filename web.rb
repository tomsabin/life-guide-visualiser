require 'sinatra'
require 'json'
require 'fileutils'
require 'find'
require 'iconv'
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
  nodes, links = [], []
  lgil_file = Iconv.new("UTF-8//IGNORE", "UTF-8").iconv(File.open('uploads/' + 'intervention.lgil', "r").read).split(/\r\n/)
  clean_lgil(lgil_file)
  create_nodes(nodes, links)
  find_sections(nodes)
  parse_lgil
  parse_xml
  links.uniq!
  nodes.each { |x| puts x.inspect }
  # links.each { |x| puts x.inspect }
  FileUtils.rm_rf('uploads/.')
  { 
    :nodes => nodes,
    :links => links
  }.to_json
end