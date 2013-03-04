require 'json'

class Node
  def initialize(name, group)
    @name = name
    @group = group
    @connected_vetices = []
  end
  
  def name
    @name
  end
  
  def add_node(name)
    @connected_vetices.push(name) #name of node is unique
  end
  
  def to_json(*a)
    {
      'name' => @name,
      'group' => @group
    }.to_json(*a)
  end

  def self.json_create(o)
    new(*o['data'])
  end
end