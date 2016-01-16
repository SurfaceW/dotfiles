# encoding: utf-8

require_relative 'pattern.rb'

class Entry
  EMPTY_TAGS = [].freeze

  attr_accessor :patterns, :tags
  attr_reader :basepath, :relpath, :path, :found_rows
  def initialize(basepath, relpath, patterns)
    @basepath = basepath
    @relpath = relpath
    @path = @relpath ? File.join(@basepath, @relpath) : @basepath
    @patterns = patterns
    @tags = EMPTY_TAGS
  end
  def to_path; @path; end
  def filename; File.basename(@path); end
  def basename; File.basename(@path, '.*'); end
  def extname; x = File.extname(@path); x.empty? ? x : x[1..-1]; end
  def pathname; @relpath || filename; end
  def abspath; File.expand_path(@path); end
  def abbrpath
    @@homedir_re ||= Regexp.new('^' + Regexp.escape(Dir.home) + '(/|$)')
    abspath.sub(@@homedir_re, '~\1')
  end
  def distinct_pathname
    if @relpath
      File.join(File.basename(@basepath), @relpath)
    else
      File.join(File.basename(File.dirname(@basepath)), File.basename(@basepath))
    end
  end
  def direct_child?
    @direct_child = !@relpath.include?('/') unless defined?(@direct_child)
    @direct_child
  end

  def stat
    unless @stat_access
      @stat_access = true
      @stat = begin
        File.stat(@path)
      rescue Errno::ENOENT, Errno::EACCES, Errno::ENOTDIR, Errno::ELOOP, Errno::ENAMETOOLONG
      end
    end
    @stat
  end
  def file?; stat ? stat.file? : false; end
  def directory?; stat ? stat.directory? : false; end
  def mtime; stat ? stat.mtime : nil; end
  def size; stat ? stat.size : nil; end

  def grep
    @found_rows = File.open(@path, 'r:utf-8') do |io|
      begin
        adaptive_grep(io)
      rescue ArgumentError
      end
    end
  end

  ANY_MATCHED = [].freeze
  def adaptive_grep(io)
    c_patterns, g_patterns = patterns.partition {|p| p.value_for_target(:grep) == :any }
    if c_patterns.empty?
      found_rows = []
      io.each_line.with_index(1) do |s, i|
        c = 0
        found_rows << [s, i, c + 1] if g_patterns.all? {|p| m = p.match?(s); c = m if m && m != true; m }
      end
      found_rows unless found_rows.empty?
    elsif g_patterns.empty?
      ng, unfound = c_patterns.partition(&:inverted)
      io.each_line do |s|
        return if ng.any? {|p| s =~ p.re }
        return ANY_MATCHED if unfound.delete_if {|p| s =~ p.re }.empty? && ng.empty?
      end
      ANY_MATCHED if unfound.empty?
    else
      ng, unfound = c_patterns.partition(&:inverted)
      found_rows = []
      io.each_line.with_index(1) do |s, i|
        return if ng.any? {|p| s =~ p.re }
        unfound.delete_if {|p| s =~ p.re }
        c = 0
        found_rows << [s, i, c + 1] if g_patterns.all? {|p| m = p.match?(s); c = m if m && m != true; m }
      end
      found_rows if unfound.empty? && !found_rows.empty?
    end
  end

  def self.sortkey_to_method(key, group_direct_children)
    method_name = :"sortkey_#{key}"
    if group_direct_children
      -> e { [e.first_priority, e.send(method_name)] }
    else
      method_name
    end
  end
  def sortkey_name; pathname; end
  def sortkey_mtime; -(mtime || Time.at(0)).to_i; end
  def sortkey_extname; [extname.empty? ? 1 : 0, extname]; end
  def sortkey_size; [file? ? -size : 1, pathname]; end
  def first_priority
    return 0 unless @relpath
    return 1 if direct_child? && file?
    2
  end
end

class Entry
  def self.select(query)
    return enum_for(__method__, query) unless block_given?

    opts = query.search_opts
    recursive = opts.recursive
    file_only = opts.file_type == :file
    dir_only = opts.file_type == :directory
    hidden_only = opts.dotmatch == :hidden
    glob_opts = opts.dotmatch == :visible ? 0 : File::FNM_DOTMATCH
    dots = {'.' => true, '..' => true}
    patterns = query.patterns
    simple, possible, defferd = Patterns.group(patterns, :name)
    opts.search_paths.each do |path|
      glob(path, recursive, glob_opts) do |f|
        f.encode!('UTF-8', 'UTF8-MAC')
        if glob_opts == File::FNM_DOTMATCH
          basename = File.basename(f)
          next if dots.key?(basename)
          next if hidden_only && basename[0] != '.'
        end
        next if file_only && !File.file?(f)
        next if dir_only && !File.directory?(f)
        e = Entry.new(path, f[path.length + (path.end_with?('/') ? 0 : 1) .. -1], nil)
        m = Patterns.test_by_group(:name, simple, possible, defferd.dup) do |p|
          p.match? e.send(p.value_for_target(:name))
        end
        next unless m
        e.patterns = m
        yield e
      end
    end
  end

  def self.glob(path, recursive, glob_opts, &block)
    if File.file?(path)
      block[path] unless glob_opts == 0 && File.basename(path)[0] == '.'
    else
      glob_pattern = recursive ? File.join(path, '**', '*') : File.join(path, '*')
      Dir.glob(glob_pattern,  glob_opts, &block)
    end
  end

  def self.filter_by_tags(entries)
    return enum_for(__method__, entries) unless block_given?

    require_relative 'openmeta.rb'
    OpenMeta.each_file_with_tags(entries) do |e, tags|
      m = Patterns.test(e.patterns, :tags) do |p|
        p.match_any? tags
      end
      next unless m
      e.patterns = m
      e.tags = tags
      yield e
    end
  end

  def self.filter_by_contents(entries, show_all_lines)
    return enum_for(__method__, entries, show_all_lines) unless block_given?

    entries.each do |e|
      if show_all_lines && e.file? && !e.patterns.any? {|p| p.value_for_target(:grep) == :all }
        e.patterns << @@force_all ||= Pattern.new(//, false, {grep: :all})
      end
      next yield(e) if e.patterns.empty?
      next unless e.file?
      yield e if e.grep
    end
  end

  def self.search(q)
    opts = q.search_opts
    entries = select(q)
    if Patterns.any_target?(q.patterns, :tags) || opts.require_tags
      entries = filter_by_tags(entries)
    end
    if Patterns.any_target?(q.patterns, :grep) || opts.show_all_lines
      entries = filter_by_contents(entries, opts.show_all_lines)
    end
    entries.sort_by(&sortkey_to_method(
      opts.sort_by,
      opts.group_direct_children))
  end
end
