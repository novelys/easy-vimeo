require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "easy-vimeo"
    gem.summary = "EasyVimeo is an object wrapper around the Ruby Vimeo API to easily upload videos to Vimeo.com"
    gem.description = "EasyVimeo is an object wrapper around the Ruby Vimeo API to easily upload videos to Vimeo.com"
    gem.email = "slainer68@gmail.com"
    gem.homepage = "http://github.com/slainer68/easy-vimeo"
    gem.authors = ["slainer68"]
    
    if gem.respond_to? :specification_version then
      current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
      gem.specification_version = 3

      if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
        gem.add_runtime_dependency(%q<vimeo>, [">= 1.0.0"])
        gem.add_runtime_dependency(%q<httpclient>, [">= 2.1.5"])
      else
        gem.add_dependency(%q<vimeo>, [">= 1.0.0"])
        gem.add_dependency(%q<httpclient>, [">= 2.1.5"])
      end
    else
      gem.add_dependency(%q<vimeo>, [">= 1.0.0"])
      gem.add_dependency(%q<httpclient>, [">= 2.1.5"])
    end
    
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "easy-vimeo #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

