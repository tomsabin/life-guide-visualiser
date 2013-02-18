@raw = []

def clean_input(raw)
  @raw = raw
  raw.map! { |line| line == "" ? "<ENDBLOCK>" : line }
end

def parse_input(nodes, links)
  @nodes, @links = nodes, links
  @raw.each do |line|
    if line =~ /show\s[^\.]*$/
      @nodes.push(Node.new(line.split(' ')[1], 0))
    end
  end
  
  @raw.each_with_index do |line, index|
    if show_token?(line)
      source_name = line.split(' ')[1]
      source_node = @nodes.find { |node| node.name if node.name == source_name }
      if show_token?(next_block(index))
        if !after_token?(@raw[index-1])
          source_index = @nodes.index(source_node)
          target_name = next_block(index).split(' ')[1]
          target_node = @nodes.find { |node| node.name if node.name == target_name }
          target_index = @nodes.index(target_node)
          source_node.add_node(target_name)
          @links.push( {:source => source_index, :target => target_index, :value => 1} )
        end
      # elsif after_token?(next_line)
        
      end

      # puts "source_name: " + source_name
      # puts "source_node: " + source_node.name
      #need to find out source index and target index in @node

    end
  end
  
  # need to make links as JSON from node list
end

def next_block(index)
  raw = @raw[index..@raw.length]
  begin 
    return raw[raw.index("<ENDBLOCK>")+1]
  rescue Exception
    return raw[raw.length]
  end
end

def after_token?(line)
  true if line =~ /after\s.*\sif\s\(.*\)\sgoto\s(.*)/ # /after\s.*\sif\s((isempty|and|or)\s)?\(.*\)\sgoto\s(.*)/
end

def show_token?(line)
  true if line =~ /show\s[^\.]*$/
end

# /show\s[^\.]*$/
# /after\s.*\sif\s\(.*\)\sgoto\s(.*)/
# /after\s.*\sif\s((isempty|and|or)\s)?\(.*\)\sgoto\s(.*)/

# links.push( {:source => 0, :target => 0, :value => 1} )