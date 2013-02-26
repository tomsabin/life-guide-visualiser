@raw = []

def clean_input(raw)
  raw.map! { |line| line == "" ? " " : line }
  raw.delete_if { |line| line =~ /^(?:(?!show|after).)+$/ }
  @raw = raw
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
      find_node(line.split(' ')[1]).change_type('show')
      if !after_token?(prev_line) and !after_token?(next_line) and show_token?(next_line)
        add_link(
          line.split(' ')[1],
          next_line.split(' ')[1],
          1
        )
      elsif after_token?(prev_line)
        add_link(
          prev_line.split(' ')[1],
          line.split(' ')[1],
          3
        )
      end
    elsif after_token?(line)
      find_node(line.split(' ')[1]).change_type('after')
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