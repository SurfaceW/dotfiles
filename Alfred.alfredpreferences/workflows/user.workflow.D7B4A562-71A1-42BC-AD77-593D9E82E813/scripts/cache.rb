# encoding: utf-8

module Cache
  def self.mtime(file)
    File.mtime(file) if File.exist?(file)
  end

  def self.clear(file)
    File.open(file, 'w:utf-8') {} if File.exist?(file)
  end

  def self.write(file, contents)
    File.open(file, 'w:utf-8') {|f| f.write(Array(contents).join("\n")) }
  end

  def self.get(file, default = nil)
    if File.exist?(file)
      contents = File.read(file,  :encoding => 'UTF-8')
      return contents unless contents.empty?
    end
    default
  end

  def self.get_or_create(file)
    contents = get(file)
    unless contents
      contents = yield
      write(file, contents)
    end
    contents
  end

  def self.get_lines(file)
    return [] unless File.exist?(file)

    File.open(file, 'r:utf-8') do |io|
      if block_given?
        a = []
        io.each do |s|
          s = yield(s.chomp)
          a << s if s
        end
        a
      else
        io.map(&:chomp)
      end
    end
  end

  def self.get_paths(file)
    get_lines(file) {|path| path if File.exist?(path) }
  end
end
