require 'json'

class Node
  def initialize(name, group)
    @name = name
    @group = group
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

class Vertices
  def initialize(source, target, value)
    @source = source
    @target = target
    @value = value
  end
  
  def to_json(*a)
    {
      'source' => @source,
      'target' => @target,
      'value' => @value
    }.to_json(*a)
  end

  def self.json_create(o)
    new(*o['data'])
  end
end