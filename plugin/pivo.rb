require 'pivotal-tracker'

# Usage: ruby pivo.rb print_stories API_TOKEN PROJECT_ID

class Pivo
  attr_reader :project

  def initialize(token, project_id)
    PivotalTracker::Client.use_ssl = true
    PivotalTracker::Client.token = token
    @project = PivotalTracker::Project.find(project_id)
  end

  def print_stories
    project.stories.all.each do |story|
      puts "[##{story.id}] - {#{story.current_state}} - #{story.name}"
    end
  end
end

pivo = Pivo.new(ARGV[1], ARGV[2])
case ARGV[0]
when 'print_stories'
  pivo.print_stories
end
