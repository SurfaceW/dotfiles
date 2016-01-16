require 'cgi/util'
require_relative 'filter_item.rb'

class FileCreationItem < FilterItem
  def self.create(query, opts)
    klass = case opts.fetch(:enable_file_creation, :file)
    when :file
      FileCreationItem
    when :note
      NoteCreationItem
    end
    return nil unless klass

    item = klass.new(query, opts)
    item.has_uniq_name? ? item : nil
  end

  def initialize(query, opts = {})
    @query = query.raw_query
    @base_dir = resolve_base_dir(query.search_opts.search_paths)
    @args = Array(opts[:file_creation_args])
    @opts = opts
  end

  def resolve_base_dir(search_paths)
    unless search_paths.empty?
      dir = search_paths[0]
      File.file?(dir) ? File.dirname(dir) : dir
    end
  end

  def abbr_homedir(path)
    @@homedir_re ||= Regexp.new('^' + Regexp.escape(Dir.home) + '(/|$)')
    path.sub(@@homedir_re, '~\1')
  end

  def clean_query
    @clean_query ||= (@query.each_line.first || '').strip
  end

  def path
    @path ||= if clean_query.empty?
      ""
    elsif clean_query =~ /^[\/~]/
      if @opts[:allow_absolute_path_in_file_creation]
        File.expand_path(clean_query)
      else
        ""
      end
    elsif @base_dir.nil?
      ""
    else
      File.expand_path(File.join(@base_dir, clean_query))
    end
  end

  def has_uniq_name?
    if path.empty? || File.exist?(path)
      false
    else
      true
    end
  end

  def dir?
    clean_query.end_with?('/')
  end

  def filetype
    dir? ? 'Directory' : 'File'
  end

  def basename
    File.basename(path, '.*')
  end

  def filename
    File.basename(path)
  end

  def dirname
    File.dirname(path)
  end

  def item_arg
    '+' + CGI.escape(@query)
  end

  def item_title
    %[New #{filetype} "#{filename}"]
  end

  def item_subtitle
    abbr_homedir(path)
  end

  def item_subtitle_shift
    'Create and open'
  end

  def item_icon_type
    @opts[:file_creation_icon] ? nil : 'filetype'
  end

  def item_icon
    @opts[:file_creation_icon] || (dir? ? 'public.directory' : 'public.source-code')
  end

  def create_file
    require 'fileutils'
    if dir?
      FileUtils.mkdir_p(path)
    else
      FileUtils.mkdir_p(dirname)
      FileUtils.touch(path)
    end
    nil
  end

  def notification
    item_subtitle
  end
end

class NoteCreationItem < FileCreationItem
  def note_default_tags
    Array(@opts[:file_creation_args]).map(&:to_s)
  end

  def note_title_and_tags
    @note_title_and_tags ||= -> {
      words = clean_query.split
      tags = words.grep(/^@\w+$/)
      tags += note_default_tags if tags.empty?
      [(words - tags).join(' '), tags]
    }[]
  end

  def note_title
    note_title_and_tags[0]
  end

  def note_tags
    note_title_and_tags[1]
  end

  def note_body
    @note_body ||= -> {
      warn @query.inspect
      a = @query.each_line.with_index(1).map do |str, line|
        line == 1 ? note_title : str.chomp
      end
      a.length == 1 ? [] : a
    }[]
  end

  def path
    @path ||= if clean_query.empty? || @base_dir.nil? || note_title.empty?
      ""
    else
      File.join(File.expand_path(@base_dir), note_title.tr('/', ':') + '.txt')
    end
  end

  def item_title
    %[Add Note "#{basename}"]
  end

  def item_subtitle
    note_tags.join(' ')
  end

  def create_file
    File.open(path, 'w:utf-8') do |f|
      f.puts(note_body.join("\n")) unless note_body.empty?
    end
    require_relative 'openmeta.rb'
    OpenMeta.set_tags(note_tags, [path])
    1 + note_body.length
  end

  def notification
    basename
  end
end
