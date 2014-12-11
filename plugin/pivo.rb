require 'pivotal-tracker'

# Usage: ruby pivo.rb <operation> <api_token> <project_id> [<params>]

class Pivo
  attr_reader :project
  STATES_MAP = {
    'unscheduled' => ' ? ',
    'unstarted'   => ' s ',
    'started'     => ' f ',
    'finished'    => ' d ',
    'delivered'   => 'a/r',
    'accepted'    => ' + ',
    'rejected'    => '-s-',
  }

  def initialize(token, project_id)
    PivotalTracker::Client.use_ssl = true
    PivotalTracker::Client.token = token
    @project = PivotalTracker::Project.find(project_id)
  end

  def print_stories(*)
    project.stories.all.each do |story|
      puts line_for(story)
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

  def line_for(story)
    "  #{id_for(story)} #{state_for(story)} #{story.name} #{author_for(story)}"
  end

  def id_for(story)
    "[##{story.id}]"
  end

  def state_for(story)
    "[#{STATES_MAP[story.current_state]}]"
  end

  def author_for(story)
    "(#{story.owned_by})" unless story.owned_by.nil?
  end
end

raise NoMethodError unless Pivo.method_defined?(ARGV[0])
Pivo.new(ARGV[1], ARGV[2]).public_send(ARGV[0], ARGV[3])
