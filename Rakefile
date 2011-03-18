require 'rubygems'
require 'bundler'
require 'rspec/core/rake_task'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "freshmeat"
  gem.homepage = "http://github.com/mrevil/freshmeat"
  gem.license = "Apache"
  gem.summary = "A simple wrapper around the Freshmeat.net API"
  gem.description = "A simple wrapper around the Freshmeat.net API"
  gem.email = "mstump@matthewstump.com"
  gem.authors = ["Matthew Stump"]
  gem.add_runtime_dependency 'httparty', '>= 0.4.2'
  gem.add_development_dependency 'rspec', '>= 2.5.0'
  gem.add_development_dependency 'jeweler', '~> 1.5.2'
  gem.add_development_dependency 'bundler', '~> 1.0.0'
  gem.add_development_dependency 'fakeweb', '>= 1.3.0'
end
Jeweler::RubygemsDotOrgTasks.new

task :spec do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w{--colour --format progress}
  end
end

task :rcov do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w{--colour --format progress}
    t.rcov = true
    t.rcov_opts = ['-T', '--exclude', 'spec,gems']
  end
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "freshmeat #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
