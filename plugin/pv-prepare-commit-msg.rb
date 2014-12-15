#!/usr/bin/env ruby
story_path = '/tmp/current_pivo.id'
if File.exists?(story_path)
  story_id = File.read(story_path).strip
  if story_id =~ /(\d{7,})/
    puts IO.read(ARGV[0])
    commit_msg = IO.read(ARGV[0])
    unless commit_msg.include?($1) or commit_msg =~ /Merge branch/
      File.open(ARGV[0], 'w') do |file|
        file.print story_id
        file.print commit_msg
      end
    end
  end
end
