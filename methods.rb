@raw = []

def clean_lgil(raw)
  raw.delete_if { |line| line == '' }
  raw.keep_if { |line| line =~ /^(show\s[^\.]+(if\s.+)?$|after.+$|begin(\ssection)?.*$|end(\ssection)?.*)/ }
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
  begin_count = @raw.count { |line| begin_token?(line) }
  end_count = @raw.count { |line| end_token?(line) }
  begin_count.times { find_section(@sections) } if begin_count == end_count
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
  section_name = @raw.find { |line| begin_token?(line) }
  arr.push({
    :section_name => section_name.split(' ').last,
    :begin_index => @raw.find_index { |line| begin_token?(line) } + 1,
    :end_index => @raw.find_index { |line| end_token?(line) } - 1
  })
  @raw[@raw.find_index { |line| begin_token?(line) }] = 'deleteme'
  @raw[@raw.find_index { |line| end_token?(line) }] = 'deleteme'
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
    if jumpto_link_token?(line)
      add_link(
        source_name,
        line.split(/\?jumpto=/).last.split(/("|')/).first,
        1,
        "jumpto"
      )
    end
  end
end

def div_link_token?(line)
  true if line =~ /<div.*id=("|')button-[A-z0-9_-]*("|').*class=("|')submit-jumpto-button("|').*label=("|')[A-z0-9_-]*("|').*/
end

def jumpto_link_token?(line)
  true if line =~ /<a.*href=("|')\?jumpto=[A-z0-9_-]*("|').*/
end

def show_token?(line)
  true if line =~ /show\s[^\.]+(if\s.+)?$/
end

def after_token?(line)
  true if line =~ /after\s.*\sif\s((isempty|and|or)\s)?\(.*\)\s?goto\s(.*)/
end

def section_token?(line) #
  true if line =~ /begin\ssection\s[A-z0-9_-]+/
end

def begin_token?(line)
  true if line =~ /^begin(\ssection)?.*/
end

def end_token?(line)
  true if line =~ /^end(\ssection)?.*/
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

#http://stackoverflow.com/questions/4136248/how-to-generate-a-human-readable-time-range-using-ruby-on-rails
def readable_time(secs)
  [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
    if secs > 0
      secs, n = secs.divmod(count)
      "#{n.to_i} #{name}"
    end
  }.compact.reverse.join(' ')
end