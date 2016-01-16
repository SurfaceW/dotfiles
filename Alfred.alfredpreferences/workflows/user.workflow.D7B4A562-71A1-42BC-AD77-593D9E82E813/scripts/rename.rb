# encoding: utf-8

require_relative 'alfred_trigger.rb'
require_relative 'cache.rb'

TARGETS = 'cache.rename_target.txt'

args = ARGV.map {|e| e.encode('UTF-8', 'UTF8-MAC') }
case args[0]
when 'file_action'
	path = args[1]
	Cache.write(TARGETS, path)

	basename = File.basename(path, '.*')
	Alfred.trigger_internal('rename_callback', basename)

when 'rename'
	path = Cache.get_paths(TARGETS)[0]
	unless path
		print "Error: Can't find source"
		exit
	end

	to_filename = File.basename(args[1]) + File.extname(path)
	to_path = File.join(File.dirname(path), to_filename)
	if File.exist?(to_path)
		print "Error: Target already exists"
		exit
	end

	begin
		File.rename(path, to_path)
	rescue
		print "Error"
		exit
	end

	print "#{to_filename}"

end

