require 'json'

class Node
  def initialize(name, group)
    @name = name
    @group = group
    @connected_vetices = []
  end
  
  def add_node(node_id)
    @connected_vetices.push(node_id)
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