require 'pivotal-tracker'

# Usage: ruby pivo.rb <operation> API_TOKEN PROJECT_ID [<params>]

class Pivo
  attr_reader :project

  def initialize(token, project_id)
    PivotalTracker::Client.use_ssl = true
    PivotalTracker::Client.token = token
    @project = PivotalTracker::Project.find(project_id)
  end

  def print_stories(*)
    project.stories.all.each do |story|
      puts "  [##{story.id}] - {#{story.current_state}} #{story.name} {#{story.owned_by}}"
    end
  end

  %w(start finish deliver accept reject).each do |operation|
    define_method(operation) do |story_id|
      find(story_id).update(current_state: "#{operation}ed")
    end
  end

  private

  def find(story_id)
    @project.stories.find(story_id)
  end
end

raise NoMethodError unless Pivo.method_defined?(ARGV[0])
Pivo.new(ARGV[1], ARGV[2]).public_send(ARGV[0], ARGV[3])
