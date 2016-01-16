# encoding: utf-8

module Settings
  def self.default
    @@default ||= load('settings.json') || {}
  end

  def self.load(file)
    return nil if file.nil? || file.empty? || !File.exist?(file)

    begin
      require 'json'
      o = JSON.parse(File.read(file,  :encoding => 'UTF-8'))
      deep_symbolize(o) if o.is_a?(Hash)
    rescue
      nil
    end
  end

  def self.deep_symbolize(hash)
    h = {}
    hash.each {|k, v| h[k.to_s.to_sym] = deep_symbolize_value(v) }
    h
  end

  def self.deep_symbolize_value(o)
    case o
    when Hash
      deep_symbolize(o)
    when Array
      o.map(&method(__method__))
    when String
      case o
      when /^\\:/
        o[1..-1]
      when /^:/
        o[1..-1].to_sym
      else
        o
      end
    else
      o
    end
  end
end
