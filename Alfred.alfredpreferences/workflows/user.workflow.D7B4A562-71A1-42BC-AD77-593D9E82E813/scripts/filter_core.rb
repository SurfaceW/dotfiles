# encoding: utf-8

require 'date'
require_relative 'entry.rb'
require_relative 'filter_item.rb'
require_relative 'location.rb'

class FoundItem < FilterItem
  attr_reader :file_ref

  def initialize(file_ref, opts = {})
    @file_ref = file_ref
    @opts = opts
    @cached_vars = {}
  end

  def self.vars
    @@vars ||= {}
    @@vars[self] ||= (self == FoundItem ? {} : superclass.vars).merge(
      Hash[
        instance_methods(false).grep(/^var_(.+)$/) {|m| [$1.to_sym, m] }
      ])
  end

  def self.to_methods(names)
    a = []
    vars = self.vars
    Array(names).each do |name|
      a << vars[name] if vars.key?(name)
    end
    a unless a.empty?
  end

  def cached_send(method)
    if @cached_vars.key?(method)
      @cached_vars[method]
    else
      @cached_vars[method] = send(method)
    end
  end

  def expand_text(methods)
    a = []
    methods.each do |m|
      s = cached_send(m)
      a << s unless s.nil? || s.empty?
    end
    a.join(' ') unless a.empty?
  end

  def var_absolute_pathname
    @file_ref.abspath
  end

  def var_home_relative_pathname
    @file_ref.abbrpath
  end

  def var_pathname
    @opts[:use_distinct_pathname] ? @file_ref.distinct_pathname : @file_ref.pathname
  end

  def var_pathname_unless_direct_child
    @opts[:use_distinct_pathname] ? @file_ref.distinct_pathname
      : (@file_ref.direct_child? ? nil : @file_ref.pathname)
  end

  def var_filename
    @file_ref.filename
  end

  def var_basename
    @file_ref.basename
  end

  def var_tags
    @file_ref.tags.join(' ')
  end

  def var_date_modified
    mtime = @file_ref.mtime
    if mtime
      if mtime >= TIME_TODAY
        mtime.strftime('Today %H:%M')
      elsif mtime >= TIME_YESTERDAY
        mtime.strftime('Yesterday %H:%M')
      else
        mtime.strftime('%Y/%m/%d %H:%M')
      end
    end
  end

  TIME_TODAY = Date.today.to_time
  TIME_YESTERDAY = (Date.today - 1).to_time

  def var_size
    if @file_ref.file?
      size = @file_ref.size
      FILE_SIZE_UNITS.each_pair { |e, s| return "#{(size.to_f / (s / 1000)).round(2)}#{e}" if size < s }
    end
  end

  FILE_SIZE_UNITS = {
    'B'  => 1000 ** 1,
    'KB' => 1000 ** 2,
    'MB' => 1000 ** 3,
    'GB' => 1000 ** 4,
    'TB' => 1000 ** 5,
  }
end

class FileItem < FoundItem
  def self.parse_options(q, s, d = {})
    d[:file_title] = to_methods(s[:file_title]) || [:var_filename]
    d[:file_subtitle] = to_methods(s[:file_subtitle]) || sortkey_to_props(q.search_opts.sort_by)
    d[:file_text_copy] = to_methods(s[:file_text_copy]) || []
    d[:file_text_largetype] = to_methods(s[:file_text_largetype]) || [:var_home_relative_pathname]
    d[:file_icon] = s[:file_icon]
    d[:file_icon_type] = s[:file_icon] ? nil : 'fileicon'
    d
  end

  def self.sortkey_to_props(key)
    case key
    when :name, :extname
      [:var_tags, :var_pathname]
    when :mtime
      [:var_date_modified, :var_tags, :var_pathname_unless_direct_child]
    when :size
      [:var_size, :var_tags, :var_pathname_unless_direct_child]
    else
      []
    end
  end

  attr_reader :location
  def initialize(file_ref, opts = {})
    super
    path = file_ref.path
    @location = path.start_with?('/') ? path : Location.encode_path(path)
  end

  alias_method :item_arg, :location

  def item_type
    FILE_ITEM_TYPE
  end

  def item_title
    expand_text(@opts[:file_title])
  end

  def item_subtitle
    expand_text(@opts[:file_subtitle])
  end

  def item_icon_type
    @opts[:file_icon_type]
  end

  def item_icon
    @opts[:file_icon] || @file_ref.abspath
  end

  def item_text_copy
    expand_text(@opts[:file_text_copy])
  end

  def item_text_largetype
    expand_text(@opts[:file_text_largetype])
  end

  FILE_ITEM_TYPE = 'file:skipcheck'
end

class LineItem < FoundItem
  def self.parse_options(q, s, d = {})
    d[:line_title] = to_methods(s[:line_title]) || [:var_trimmed_contents]
    d[:line_subtitle] = to_methods(s[:line_subtitle]) || [:var_pathname, :var_line_number]
    d[:line_text_copy] = to_methods(s[:line_text_copy]) || [:var_trimmed_contents]
    d[:line_text_largetype] = to_methods(s[:line_text_largetype])  || [:var_trimmed_contents]
    d[:line_icon] = s[:line_icon]
    d
  end

  RM_TAGS_RE = /(?:^|\s+)@\w+(?:\s+@\w+)*\s*$/
  RM_MARK_RE = Regexp.new('(?:^#{1,6} |^\s*[\*\+-] |^\s*)(\S.*)$')

  attr_reader :location
  def initialize(file_ref, str, line, column, opts = {})
    super(file_ref, opts)
    @str = str.chomp
    @line = line
    @location = Location.encode_line(file_ref.path, str, line, column)
  end

  def var_trimmed_contents
    @str.strip
  end

  def var_contents_without_tags
    @str.sub(RM_TAGS_RE, '').sub(RM_MARK_RE, '\1')
  end

  def var_contents
    @str
  end

  def var_line_number
    @line.to_s
  end

  alias_method :item_arg, :location

  def item_title
    expand_text(@opts[:line_title])
  end

  def item_subtitle
    expand_text(@opts[:line_subtitle])
  end

  def item_icon_type
    nil
  end

  def item_icon
    @opts[:line_icon]
  end

  def item_text_copy
    expand_text(@opts[:line_text_copy])
  end

  def item_text_largetype
    expand_text(@opts[:line_text_largetype])
  end
end

module FilterOutput
  def self.output_options(query, opts)
    o = { use_distinct_pathname: query.search_opts.search_paths.size > 1 }
    FileItem.parse_options(query, opts, o)
    LineItem.parse_options(query, opts, o)
    o
  end

  def self.each_found_item(query, opts)
    return enum_for(__method__, query, opts) unless block_given?

    Entry.search(query).each do |e|
      found_line = false
      rows = e.found_rows
      if rows
        rows.each do |s, i, c|
          item = LineItem.new(e, s, i, c, opts)
          if item.item_title
            found_line = true
            yield item
          end
        end
      end
      unless found_line
        yield FileItem.new(e, opts)
      end
    end
  end
end
