# encoding: utf-8

module Alfred
  def self.trigger(workflow, trigger_name, arg = nil)
    command = ['osascript', '-e', TRIGGER_SCRIPT, workflow, trigger_name]
    command << arg if arg
    system(*command)
  end

  def self.trigger_internal(trigger_name, arg = nil)
    trigger(bundle_id, trigger_name, arg) unless bundle_id.empty?
  end

  def self.search(arg = '')
    system('osascript', '-e', SEARCH_SCRIPT, arg)
  end

  def self.bundle_id
    @@bundle_id ||= begin
      require 'shellwords'
      `defaults read #{Shellwords.shellescape(File.expand_path('info'))} bundleid`.chomp
    end
  end

  TRIGGER_SCRIPT = <<EOS
on run argv
  if length of argv is 2 then
    tell application "Alfred 2" to run trigger (item 2 of argv) in workflow (item 1 of argv)
  else if length of argv is 3 then
    tell application "Alfred 2" to run trigger (item 2 of argv) in workflow (item 1 of argv) with argument (item 3 of argv)
  end if
end run
EOS

  SEARCH_SCRIPT = <<EOS
on run argv
  tell application "Alfred 2" to search (item 1 of argv)
end run
EOS

end
