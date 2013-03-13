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
  FileUtils.rm_rf('uploads/.')
  { 
    :nodes => nodes,
    :links => links
  }.to_json
end

post '/processSessions/?' do
  sessions = {}
  request.env["rack.input"].read["session_data"].each do |session|
    session["visited_nodes"].each_with_index do |node, index|
      unless index == session["visited_nodes"].size-1
        puts "#{index} (#{session["visited_nodes"].size}): #{node} -- #{session["visited_nodes"][index+1]["node_name"]}"
      end

    #   current_name = node["node_name"]
    #   next_name = session["visited_nodes"][index+1]["node_name"]
    #   if sessions["lineid_"+current_name+next_name]
    #     sessions["lineid_"+current_name+next_name] += 1
    #   else
    #     sessions["lineid_"+current_name+next_name] = 1
    #   end
    end
  end
  
  #return the id of the link (lineid__sourcenametargetname) and the number of visits 
  # {
  #   "lineid_sourcenametargetname" => 1
  # }
  sessions.to_json
end