# encoding: utf-8

require_relative 'filter_core.rb'

class ParentItem < FileItem
  def item_title
    '..'
  end

  def item_subtitle
    @file_ref.abbrpath
  end
end

module FilterOutput
  def self.generate(query, opts, out)
    out << "<?xml version='1.0'?><items>\n"
    if location = opts.fetch(:restore_cursor, true) && query.same_as_last? && Location.get
      found, rest = false, []
      each_item(query, opts) do |item|
        found = true if !found && item.item_arg == location
        found ? item.build_xml(out) : (rest << item)
      end
      rest.each {|item| item.build_xml(out) }
    else
      each_item(query, opts) {|item| item.build_xml(out) }
    end
    out << "</items>\n"
  end

  def self.each_item(query, opts, &block)
    return enum_for(__method__, query, opts) unless block

    output_opts = output_options(query, opts)
    if opts.fetch(:show_parent_dir, true) && Validator::BLANK_RE === query.raw_query
      if parent = query.search_opts.parent_path
        block[ParentItem.new(Entry.new(parent, nil, nil), output_opts)]
      end
    end
    if opts[:show_file_creation_item_first]
      file_creation_item(query, opts, &block)
      each_found_item(query, output_opts, &block)
    else
      each_found_item(query, output_opts, &block)
      file_creation_item(query, opts, &block)
    end
  end

  def self.file_creation_item(query, opts)
    mode = opts.fetch(:enable_file_creation, :file)
    if mode == :file || mode == :note
      require_relative 'creation_item.rb'
      if item = FileCreationItem.create(query, opts)
        yield item
      end
    end
  end
end

if __FILE__ == $0
  require_relative 'query.rb'

  q = ARGV[0].encode('UTF-8', 'UTF8-MAC')
  query = Query.new(q)
  query.save unless query.same_as_last?
  FilterOutput.generate(query, Settings.default, $stdout)
end

