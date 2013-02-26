require 'json'

class Node
  def initialize(name, group, type = 'none')
    @name = name
    @group = group
    @type = type
    @connected_vetices = []
  end
  
  def name
    @name
  end
  
  def change_type(type)
    @type = type
  end
  
  def add_node(name)
    @connected_vetices.push(name) #name of node is unique
  end
  
  def to_json(*a)
    {
      'name' => @name,
      'group' => @group,
      'type' => @type,
    }.to_json(*a)
  end

  def self.json_create(o)
    new(*o['data'])
  end
end