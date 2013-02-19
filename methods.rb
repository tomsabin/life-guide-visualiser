@raw = []

def clean_input(raw)
  @raw = raw
  raw.map! { |line| line == "" ? "<ENDBLOCK>" : line } #--- not sure if this is best way
end

def parse_input(nodes, links)
  @nodes, @links = nodes, links
  @raw.each do |line|
    if line =~ /show\s[^\.]*$/
      @nodes.push(Node.new(line.split(' ')[1], 0))
    end
  end
  
  @raw.each_with_index do |line, index|
    prev_line = @raw[index-1]
    next_line = @raw[index+1]
    if show_token?(line)
      if after_token?(prev_line)
        add_link(
          prev_line.split(' ')[1],
          line.split(' ')[1],
          3
        )
      elsif show_token?(next_show(index)) #--- this might cause problems in the future
        if !after_token?(prev_line) and !after_token?(next_line)
          add_link(
            line.split(' ')[1],
            next_show(index).split(' ')[1],
            1
          )
        end
      end
    elsif after_token?(line)
      add_link(
        line.split(' ')[1],
        line.split(' ').last,
        2
      )
    end
  end
end

def show_token?(line)
  true if line =~ /show\s[^\.]*$/
end

def after_token?(line)
  true if line =~ /after\s.*\sif\s((isempty|and|or)\s)?\(.*\)\sgoto\s(.*)/
end

def next_show(index) #--- this might need rebuilding
  raw = @raw[index..@raw.length]
  begin 
    return raw[raw.index("<ENDBLOCK>")+1]
  rescue Exception
    return raw[raw.length]
  end
end

def find_node(name)
  @nodes.find { |node| node.name if node.name == name }
end

def add_link(source_name, target_name, value)
  find_node(source_name).add_node(target_name)
  @links.push( {
    :source => @nodes.index(find_node(source_name)),
    :target => @nodes.index(find_node(target_name)),
    :value => value
  } )
end