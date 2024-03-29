require 'json'

class Node
  def initialize(name, group)
    @name = name
    @group = group
    @group_name = ''
    @connected_nodes = []
  end
  
  def name
    @name
  end
  
  def group_name
    @group_name
  end
  
  def add_group(group_name)
    @group_name = group_name
  end
  
  def change_group_colour(int)
    @group = int
  end
  
  def add_node(name)
    @connected_nodes.push(name) #name of node is unique
    @connected_nodes.uniq!
  end
  
  def to_json(*a)
    {
      'name' => @name,
      'group' => @group,
      'group_name' => @group_name,
      'connected_nodes' => @connected_nodes
    }.to_json(*a)
  end

  def self.json_create(o)
    new(*o['data'])
  end
end