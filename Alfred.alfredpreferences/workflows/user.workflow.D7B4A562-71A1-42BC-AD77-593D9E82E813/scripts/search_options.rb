# encoding: utf-8

module Validator
  BLANK_RE = /\A[[:space:]]*\z/

  module_function

  def blank?(value)
    value.respond_to?(:empty?) ? !!value.empty? : !value
  end

  def present?(value)
    !blank?(value)
  end

  def presence_or_default(value, default = nil)
    present?(value) ? value : (block_given? ? yield : default)
  end

  def member_or_default(value, values, default = nil)
    values.member?(value) ? value : (block_given? ? yield : default)
  end

  def bool_or_default(value, default = nil)
    (value == true || value == false) ? value : (block_given? ? yield : default)
  end

  def case_or_default(value, object, default = nil)
    object === value ? value : (block_given? ? yield : default)
  end

  def any_case_or_default(value, cases, default = nil)
    cases.any? {|e| e === value } ? value : (block_given? ? yield : default)
  end

  def all_case_or_default(value, cases, default = nil)
    cases.all? {|e| e === value } ? value : (block_given? ? yield : default)
  end

  def present_str_or_default(value, default = nil)
    (value.is_a?(String) && BLANK_RE === value) ? value : (block_given? ? yield : default)
  end
end

module PathHelper
  def self.each_ancestor(path)
    return enum_for(__method__, path) unless block_given?
    unless path.nil? || path.empty? || path == '.' || path == '/'
      begin
        path = File.dirname(path)
        yield path
      end until path == '.' || path == '/'
    end
  end

  def self.reduce(paths)
    existing_paths = []
    paths.each do |path|
      if path.is_a?(String)
        path = File.expand_path(path)
        existing_paths << File.realpath(path) if File.exists?(path)
      end
    end
    existing_paths.uniq!

    hash = {}; existing_paths.each {|k| hash[k] = true }
    existing_paths.reject do |path|
      each_ancestor(path).any? {|p| hash.has_key?(p) }
    end
  end

  def self.existing_paths_or_default(paths, default = nil)
    existing_paths = reduce(paths)
    unless existing_paths.empty?
      existing_paths
    else
      (block_given? ? yield : default)
    end
  end
end

class SearchOptions
  include Validator

  attr_reader :recursive, :file_type, :dotmatch, :sort_by,
    :group_direct_children, :show_all_lines, :search_paths,
    :default_targets, :hidden_query, :opt_prefix, :mod_prefix,
    :require_tags, :parent_path

  SEARCH_PATHS_FILE = 'cache.search_paths.txt'

  def initialize(opts = nil)
    opts ||= {}
    @recursive = bool_or_default opts[:recursive], false
    @file_type = member_or_default opts[:file_type], [:file, :directory, :entry], :entry
    @dotmatch = member_or_default opts[:dotmatch], [:visible, :hidden, :all], :visible
    @sort_by = member_or_default opts[:sort_by], [:name, :mtime, :extname], :mtime
    @group_direct_children = bool_or_default opts[:group_direct_children], true
    @show_all_lines = member_or_default opts[:show_all_lines], [false, true, :auto], :auto
    @require_tags = [
      :file_title, :file_subtitle, :file_text_copy, :file_text_largetype,
      :line_title, :line_subtitle, :line_text_copy, :line_text_largetype
    ].any? do |k|
      Array(opts[k]).include?(:tags)
    end
    @search_paths = -> paths {
      PathHelper.existing_paths_or_default(Array(paths)) do
        if File.exist?(SEARCH_PATHS_FILE)
          PathHelper.existing_paths_or_default(
            File.read(SEARCH_PATHS_FILE,  :encoding => 'UTF-8').each_line.map(&:chomp))
        end
      end
    }[opts[:search_paths]] || [Dir.home]
    if @show_all_lines == :auto
      @show_all_lines = @search_paths.size == 1 && File.file?(@search_paths[0])
    end
    @parent_path = -> {
      parents = {}; @search_paths.each {|p| parents[File.dirname(p)] = true }
      parents.keys[0] if parents.size == 1
    }[]
    @default_targets = case_or_default opts[:default_targets], String, 'pg'
    @hidden_query = case_or_default opts[:hidden_query], String, ''
    @opt_prefix = present_str_or_default opts[:opt_prefix], '--'
    @mod_prefix = present_str_or_default opts[:mod_prefix], '-'
  end

  def update!(k, v)
    instance_variable_set(:"@#{k}", v)
  end
end
