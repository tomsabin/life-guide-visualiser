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
  # raw.each do |line|
  #   if line =~ /show\s[^\.]*$/
  #     nodes.push(Node.new(line.split(' ')[1], 0))
  #   end
  # end
  
  for i in 0...raw.length
    if raw[i] =~ /show\s[^\.]*$/
      current_node = Node.new(raw[i].split(' ')[1], 0)
      nodes.push(current_node)
      if raw[i+1] =~ /after\s.*\sif\s\(.*\)\sgoto\s(.*)/
        #after\s.*\sif\s((isempty|and|or)\s)?\(.*\)\sgoto\s(.*)
        current_node.add_node(raw[i+1].split(' ').last)
        if raw[i+2] =~ /show\s[^\.]*$/
          current_node.add_node(raw[i+2].split(' ').last)
        end
      end
    end
  end
  
  nodes.each { |x| puts x.inspect }

  { 
    :nodes => nodes,
    :links => links
  }.to_json
end