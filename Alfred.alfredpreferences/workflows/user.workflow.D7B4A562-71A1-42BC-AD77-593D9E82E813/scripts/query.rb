# encoding: utf-8

require_relative 'settings.rb'
require_relative 'search_options.rb'
require_relative 'pattern.rb'
require_relative 'cache.rb'

class QueryParser
  class << self
    def tokenize_re(opt_prefix, mod_prefix)
      /(?<=\s|^)(?:\/((?:[^\/\\]|\\.)*)\/|#{Regexp.escape(opt_prefix)}(\S*)|#{Regexp.escape(mod_prefix)}(\S*)|(\S+))(?=\s|$)/
    end

    def parse!(query, opts)
      patterns = []
      token_re = tokenize_re(opts.opt_prefix, opts.mod_prefix)
      builder = PatternBuilder.new(opts.default_targets)
      queries = opts.hidden_query.empty? ? [query] : [opts.hidden_query, query]
      queries.each do |q|
        q.scan(token_re) do |re, opt, mod, str|
          if re
            builder.end!(patterns)
            builder.begin!(re.gsub('\\/', '/'))
          elsif str
            builder.end!(patterns)
            builder.begin!(Regexp.escape(str))
            builder.mod!('i')
          elsif mod
            builder.mod!(mod)
          else
            opt.each_char do |o|
               kv = SHORT_OPT_TO_KV[o]
               opts.update!(*kv) if kv
            end
          end
        end
        builder.end!(patterns)
      end
      patterns
    end
  end

  class PatternBuilder
    def initialize(default_targets)
      @default_targets = {}
      default_targets.each_char do |m|
        kv = Pattern::MOD_TO_KV[m]
        @default_targets[kv[0]] = kv[1] if kv
      end
    end

    def begin!(src)
      @src = src
      @ignore_case = false
      @inverted = false
      @targets = {}
    end

    def mod!(mod)
      return unless @src
      mod.each_char do |m|
        case m
        when 'i'
          @ignore_case = true
        when 'I'
          @ignore_case = false
        when '!'
          @inverted = true
        else
          kv = Pattern::MOD_TO_KV[m]
          @targets[kv[0]] = kv[1] if kv
        end
      end
    end

    def end!(patterns)
      return unless @src

      re = begin
        Regexp.new(@src, @ignore_case)
      rescue RegexpError
      end

      if re
        @targets = @default_targets if @targets.empty?
        unless @inverted
          patterns << Pattern.new(re, false, @targets)
        else
          @targets.each do |k, v|
            patterns << Pattern.new(re, true, { k => v })
          end
        end
      end

      @src = nil
    end
  end

  SHORT_OPT_TO_KV = {
    'r' => [:recursive, true],
    'l' => [:recursive, false],
    'd' => [:file_type, :directory],
    'f' => [:file_type, :file],
    'e' => [:file_type, :entry],
    'v' => [:dotmatch, :visible],
    'h' => [:dotmatch, :hidden],
    'a' => [:dotmatch, :all],
    'n' => [:sort_by, :name],
    'm' => [:sort_by, :mtime],
    'x' => [:sort_by, :extname],
    's' => [:sort_by, :size],
    'g' => [:group_direct_children, true],
    'u' => [:group_direct_children, false],
    'A' => [:show_all_lines, true],
  }
end

class Query
  attr_reader :raw_query
  def initialize(raw_query = nil)
    @raw_query = raw_query || last_query
  end

  def parse!
    @search_opts ||= SearchOptions.new(Settings.default)
    @patterns ||= QueryParser.parse!(@raw_query, @search_opts)
  end

  def patterns
    parse!
  end

  def search_opts
    parse!
    @search_opts
  end

  def same_as_last?
    @raw_query == last_query
  end

  def last_query
    @last_query ||= Cache.get(FILE_NAME) || ''
  end

  def save
    Cache.write(FILE_NAME, @raw_query)
  end

  FILE_NAME = 'cache.query.txt'
end
