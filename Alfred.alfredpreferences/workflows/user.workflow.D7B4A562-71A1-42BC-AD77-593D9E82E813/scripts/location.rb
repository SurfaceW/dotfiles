# encoding: utf-8

require_relative 'cache.rb'

module Location
  def self.get
    unless defined?(@@location)
      @@location = begin
        location_mtime = Cache.mtime('cache.location.txt')
        query_mtime = Cache.mtime('cache.query.txt')
        if location_mtime && query_mtime && location_mtime > query_mtime
          Cache.get('cache.location.txt')
        end
      end
    end
    @@location
  end

  def self.save(location)
    Cache.write('cache.location.txt', location)
  end

  def self.encode_path(path)
    File.expand_path(path)
  end

  def self.encode_line(path, str, line, column)
    substr = str[0...(column - 1)]
    column_as_bytesize = 1 + substr.bytesize
    column_for_emacs = 1 + 2 * substr.length - substr.encode('US-ASCII', :replace => '').bytesize
    ":#{line}:#{column}:#{column_as_bytesize}:#{column_for_emacs}:#{File.expand_path(path)}"
  end

  def self.decode(str)
    case str
    when /^\//
      [str]
    when /^:([1-9][0-9]*):([1-9][0-9]*):([1-9][0-9]*):([0-9]|[1-9][0-9]*):(.*)$/
      [$5, $1.to_i, $2.to_i, $3.to_i, $4.to_i]
    end
  end
end
