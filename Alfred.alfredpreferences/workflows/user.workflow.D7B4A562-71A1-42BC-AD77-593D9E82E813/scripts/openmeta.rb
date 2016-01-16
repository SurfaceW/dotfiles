# encoding: utf-8

require 'open3'

module OpenMeta
  module ModuleMethods
    def bin
      @@bin ||= File.expand_path('openmeta', File.dirname(__FILE__))
    end

    def set_tags(tags, paths)
      o, s = Open3.capture2(bin, '-s', *tags, '-p', *paths)
      o.force_encoding('UTF-8') if s.exitstatus == 0
    end

    def each_file_with_tags(files)
      return enum_for(__method__, files) unless block_given?

      files = files ? files.to_a : []
      unless files.empty?
        Open3.popen2(bin, '-t', '-p', *files.map(&File.method(:path))) do |i, o, _|
          i.close_write
          o.set_encoding('UTF-8')
          o.each_line.with_index do |line, index|
            file = files[index]
            line[-File.path(file).length-1 .. -1] = ''
            yield file, line.split
          end
        end
      end
    end
  end
  extend ModuleMethods
end
