# encoding: utf-8

require_relative 'alfred_trigger.rb'
require_relative 'cache.rb'
require_relative 'openmeta.rb'

TARGETS = 'cache.set_tags_target.txt'

args = ARGV.map {|e| e.encode('UTF-8', 'UTF8-MAC') }
case args[0]
when 'file_action'
	paths = args[1].split("\t")
	Cache.write(TARGETS, paths)

	common_tags = nil
	OpenMeta.each_file_with_tags(paths) do |path, tags|
		unless common_tags
			common_tags = tags
		else
			common_tags &= tags
		end
	end

	Alfred.trigger_internal('tags_callback', common_tags.join(' '))

when 'set_tags'
	paths = Cache.get_paths(TARGETS)
	if paths.empty?
		print "Error: Can't find source"
	else
		tags = args[1]
		print OpenMeta.set_tags(tags.split, paths)
	end
end

