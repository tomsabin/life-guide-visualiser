@raw = []

def clean_lgil(raw)
  raw.each_with_index {|line,index| puts "#{index}: #{line}"}
  raw.map! { |line| line == "" ? " " : line }
  raw.delete_if { |line| line =~ /^(?:(?!show|after|begin).)+$/ }
  raw.each_with_index {|line,index| puts "#{index}: #{line}"}
  @raw = raw
end

def create_nodes(nodes, links)
  @nodes, @links = nodes, links
  @raw.each do |line|
    if show_token?(line)
      @nodes.push(Node.new(line.split(' ')[1], 0))
      # puts "node: #{line.split(' ')[1]}, #{@nodes.size}, from line: #{line}"
    elsif section_token?(line)
      @nodes.push(Node.new(line.split(' ')[2], 1))
    end
  end
end

def parse_lgil #this needs fixing on red labelled intervention folders
  #error: ArgumentError - invalid byte sequence in UTF-8:
  @raw.each_with_index do |line, index|
    prev_line = @raw[index-1]
    next_line = @raw[index+1]
    if show_token?(line)
      if !after_token?(prev_line) and !after_token?(next_line) and show_token?(next_line)
        add_link(
          line.split(' ')[1],
          next_line.split(' ')[1],
          1,
          "show"
        )
      elsif after_token?(prev_line)
        add_link(
          prev_line.split(' ')[1],
          line.split(' ')[1],
          3,
          "after"
        )
      end
    elsif after_token?(line)
      add_link(
        line.split(' ')[1],
        line.split(' ').last,
        2,
        "show"
      )
    end
  end
end

def parse_xml
  @nodes.each do |node|
    Dir.entries("uploads/").find do |file|
      # puts "#{node.name}, #{file}" if node.name == file[0..-5]
      parse_xml_file(node.name, file) if node.name == file[0..-5]
    end
  end
end

#need to check for duplicate links that exist already -- could cause rendering problems in the future!
def parse_xml_file(source_name, filename)
  File.open('uploads/' + filename).read.split(/\n/).each do |line|
    if div_link_token?(line)
      # puts "adding a link from #{source_name}/#{filename} to #{line.split(/label=("|')/).last.split(/("|')/).first}"
      add_link(
        source_name,
        line.split(/label=("|')/).last.split(/("|')/).first,
        4,
        "div"
      )
    end
    if a_link_token?(line)
      add_link(
        source_name,
        line.split(/\?jumpto=/).last.split(/("|')/).first,
        5,
        "a"
      )
    end
  end
end

def div_link_token?(line)
  true if line =~ /<div.*id=("|')button-[A-z0-9_-]*("|').*class=("|')submit-jumpto-button("|').*label=("|')[A-z0-9_-]*("|').*/
end

def a_link_token?(line)
  true if line =~ /<a.*href=("|')\?jumpto=[A-z0-9_-]*("|').*/
end

def show_token?(line)
  true if line =~ /show\s[A-z0-9_-]+/
end

def after_token?(line)
  true if line =~ /after\s.*\sif\s((isempty|and|or)\s)?\(.*\)\sgoto\s(.*)/
end

def section_token?(line)
  true if line =~ /begin\ssection\s[A-z0-9_-]+/
end

def find_node(name)
  @nodes.find { |node| node.name if node.name == name }
end

def add_link(source_name, target_name, value = 1, type = "none")
  # puts "---trying to find #{source_name} (#{@nodes.index(find_node(source_name))}), to add #{target_name} (#{@nodes.index(find_node(target_name))})"
  find_node(source_name).add_node(target_name)
  @links.push( {
    :source => @nodes.index(find_node(source_name)),
    :target => @nodes.index(find_node(target_name)),
    :value => value,
    :type => type
  } )
end