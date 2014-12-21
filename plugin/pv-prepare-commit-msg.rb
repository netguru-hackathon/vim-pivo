#!/usr/bin/env ruby
story_path = '/tmp/current_pivo.id'
commit_msg_file_path = ARGV[0]
if File.exists?(story_path)
  story_id = File.read(story_path).strip
  if story_id =~ /(\d{7,})/
    commit_msg = IO.read(commit_msg_file_path)
    unless commit_msg.include?($1) or commit_msg =~ /Merge branch/
      File.open(commit_msg_file_path, 'w') do |file|
        file.print "\n" + story_id
        file.print commit_msg
      end
    end
  end
end
