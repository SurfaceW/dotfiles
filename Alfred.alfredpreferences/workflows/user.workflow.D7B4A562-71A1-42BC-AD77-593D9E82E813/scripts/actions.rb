# encoding: utf-8

module Feedback
  module ModuleMethods
    def grep_in_paths(paths)
      require_relative 'alfred_trigger.rb'
      require_relative 'cache.rb'

      Cache.write('cache.search_paths.txt', paths)
      Alfred.trigger_internal('grep')
    end

    def grep_with_last_query
      require_relative 'alfred_trigger.rb'
      require_relative 'cache.rb'

      Alfred.trigger_internal('grep', Cache.get('cache.query.txt'))
    end
  end
  extend ModuleMethods
end

module FilterAction
  module ModuleMethods
    def main(arg, mod = nil)
      mod = mod.to_sym if mod
      if arg.start_with?('+')
        require_relative 'query.rb'
        require_relative 'creation_item.rb'
        if item = FileCreationItem.create(Query.new(CGI.unescape(arg[1..-1])), Settings.default)
          num_lines = item.create_file
          Cache.clear('cache.query.txt')
          case mod
          when :shift
            open([item.path, num_lines], false)
          else
            print item.notification
          end
        end
      else
        navigate_to(arg)
      end
    end

    def navigate_to(str, check_dir = true)
      require_relative 'location.rb'

      if location = Location.decode(str)
        Location.save(str)
        open(location, check_dir)
      end
    end

    private
    def open(location, check_dir = true)
      file, line, column, column_as_bytesize, column_for_emacs = location
      if line
        column ||= 1
        column_as_bytesize ||= 1
        column_for_emacs ||= 0
      end

      action = if check_dir && File.directory?(file)
        find_action(:dir_action, actions)
      elsif line.nil?
        find_action(:file_action, actions)
      else
        find_action(:line_action, actions)
      end

      if action
        require 'cgi/util'
        url = "file://#{file}"
        action.call({
          file: file,
          line: line,
          column: column,
          column_as_bytesize: column_as_bytesize,
          column_for_emacs: column_for_emacs,
          url: url,
          escaped_url: CGI.escape(url)
        })
      end
    end

    def actions
      @actions ||= begin
        require_relative 'settings.rb'
        {
          grep: -> o { Feedback.grep_in_paths(o[:file]) },
          open: -> o { system 'open', o[:file] },
          reveal_in_finder: -> o { system 'open', '-R', o[:file] },
          browse_folder_in_alfred: -> o {
            require_relative 'alfred_trigger.rb'
            Alfred.search(o[:file])
          },
          subl: -> o {
            s = o[:file]
            s << ":#{o[:line]}:#{o[:column]}" if o[:line]
            system '/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl', s
          },
          mate: -> o {
            s = "txmt://open?url=#{o[:escaped_url]}"
            s << "&line=#{o[:line]}&column=#{o[:column_as_bytesize]}" if o[:line]
            system 'open', s
          },
          mvim: -> o {
            require 'open3'
            a = ['/Applications/MacVim.app/Contents/MacOS/mvim', '--remote-silent']
            a << "+:cal cursor(#{o[:line]}, #{o[:column_as_bytesize]})" if o[:line]
            a << o[:file]
            Open3.popen3(*a) {|i, _, _, _| i.close_write }
          },
          emacs: -> o {
            a = ['/Applications/Emacs.app/Contents/MacOS/bin/emacsclient', '-n']
            a << "+#{o[:line]}:#{o[:column_for_emacs]}" if o[:line]
            a << o[:file]
            system(*a)

            if $?.exitstatus != 0
              a = ['open', '-a', '/Applications/Emacs.app', '--args', '--eval', '(server-start)']
              a << "+#{o[:line]}:#{o[:column_for_emacs]}" if o[:line]
              a << o[:file]
              system(*a)
            end
          },
          dir_action: :grep,
          file_action: :subl,
          line_action: :subl,
        }.update(Settings.default[:actions] || {})
      end
    end

    def find_action(key, actions, visited = {})
      if actions.key?(key)
        value = actions[key]
        case value
        when Symbol
          unless visited.key?(value)
            visited[value] = true
            find_action(value, actions, visited)
          end
        when Array
          unless value.empty?
            -> vars {
              begin
                args = value.map {|e| e.to_s % vars }
                system(*args)
              rescue KeyError => e
                warn e
              end
            }
          end
        when Proc
          value
        end
      end
    end
  end
  extend ModuleMethods
end

if __FILE__ == $0
  args = ARGV.map {|e| e.encode('UTF-8', 'UTF8-MAC') }
  case args[0]
  when 'filter_action'
    FilterAction.main(args[1], args[2])
  when 'grep_in_paths'
    Feedback.grep_in_paths(args[1].split("\t"))
  when 'grep_with_last_query'
    Feedback.grep_with_last_query
  end
end
