@raw = []

def clean_lgil(raw)
  # raw.map! { |line| line == "" ? " " : line }
  raw.delete_if { |line| line == '' }
  raw.delete_if { |line| line =~ /(^(?:(?!(show\s[^\.]+(if\s.+)?$)|after|begin|end).)+$|^((show\s[^\.]+(if\s.+)?$)|after|begin|end)?\t*\s*#+.*)/ }
  raw.map! { |line| line =~ /^(show|after).+(\s|\t)*#.*/ ? line.slice(0...(line.index('#'))).rstrip : line }
  @raw = raw
end

def create_nodes(nodes, links)
  @nodes, @links = nodes, links
  @raw.each do |line|
    if show_token?(line)
      @nodes.push(Node.new(line.split(' ')[1], 0))
    end
  end
end

def find_sections(nodes)
  @sections = []
  group_int = 3
  @raw.count { |line| line =~ /begin\ssection.*/ }.times do
    find_section(@sections)
  end
  @sections.each do |section|
    temp_raw = @raw[section[:begin_index]..section[:end_index]]
    temp_raw.each do |line|
      if find_node(line.split(' ')[1])
        find_node(line.split(' ')[1]).add_group(section[:section_name])
        find_node(line.split(' ')[1]).change_group_colour(group_int)
      end
    end
    group_int += 1
  end
  @raw.delete_if { |line| line == 'deleteme' }
end

def find_section(arr)
  arr.push({
    :section_name => @raw.find { |line| line =~ /begin\ssection.*/ }.split(' ')[2],
    :begin_index => @raw.find_index { |line| line =~ /begin\ssection.*/ } + 1,
    :end_index => @raw.find_index { |line| line =~ /end\ssection.*/ } - 1
  })
  @raw[@raw.find_index { |line| line =~ /begin\ssection.*/ }] = 'deleteme'
  @raw[@raw.find_index { |line| line =~ /end\ssection.*/ }] = 'deleteme'
end

def parse_lgil
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
          1,
          "after"
        )
      end
    elsif after_token?(line)
      add_link(
        line.split(' ')[1],
        line.split(' ').last,
        1,
        "show"
      )
    end
  end
end

def parse_xml
  @nodes.each do |node|
    Dir.entries("uploads/").find do |file|
      parse_xml_file(node.name, file) if node.name == file[0..-5] and file =~ /.+.(xml)/
    end
  end
end

def parse_xml_file(source_name, filename)
  File.open('uploads/' + filename).read.split(/\n/).each do |line|
    if div_link_token?(line)
      add_link(
        source_name,
        line.split(/label=("|')/).last.split(/("|')/).first,
        1,
        "div"
      )
    end
    if a_link_token?(line)
      add_link(
        source_name,
        line.split(/\?jumpto=/).last.split(/("|')/).first,
        1,
        "a_href"
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
  true if line =~ /show\s[^\.]+(if\s.+)?$/
end

def after_token?(line)
  true if line =~ /after\s.*\sif\s((isempty|and|or)\s)?\(.*\)\s?goto\s(.*)/
end

def section_token?(line)
  true if line =~ /begin\ssection\s[A-z0-9_-]+/
end

def find_node(name)
  @nodes.find { |node| node.name if node.name == name }
end

def is_section?(name)
  @nodes.find { |node| true if node.group_name == name }
end

def add_link(source_name, target_name, value = 1, type = "none")
  if not @nodes.index(find_node(target_name))
    if is_section?(target_name)
      node = @nodes.find { |node| node if node.group_name == target_name }
      target_name = node.name
    else
      @nodes.push(Node.new(target_name, 2))
    end
  end
  find_node(source_name).add_node(target_name)
  find_node(target_name).add_node(source_name)
  @links.push( {
    :source => @nodes.index(find_node(source_name)),
    :target => @nodes.index(find_node(target_name)),
    :value => value,
    :type => type
  } )
end