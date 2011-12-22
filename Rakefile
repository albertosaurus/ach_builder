task :default => :spec

require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

# Bundler is dumb, assumes when you do release you want to go to RubyGems.  Well I don't want to!
class Rake::Task
  def abandon
    prerequisites.clear
    @actions.clear
  end

  def overwrite(description = nil, &block)
    abandon
    add_description description
    enhance(&block)
  end
end

Rake::Task['release'].overwrite("DON'T DO THIS!") do
  puts "#{`whoami`.strip}, you don't want to release to RubyGems, do you?"
end

def gemspec
  @gem_spec ||= eval( open( `ls *.gemspec`.strip ){|file| file.read } )
end

def gem_version
  gemspec.version
end

def gem_version_tag
  "v#{gem_version}"
end

namespace :git do
  desc "Create git version tag #{gem_version}"
  task :tag do
    sh "git tag -a #{gem_version_tag} -m \"Version #{gem_version}\""
  end

  desc "Push git tag to GitHub"
  task :push_tags do
    sh 'git push --tags'
  end

  desc "Create git version tag #{gem_version} and push to GitHub"
  task :submit => [:tag, :push_tags] do
    puts "Deployed to GitHub."
  end
end
