require 'rubygems/dependency_installer'

di = Gem::DependencyInstaller.new

begin
  if RUBY_VERSION < '1.9.3'
    puts 'Installing backports'
    di.install 'backports', '3.3.0'
    di.install 'json_pure'
  end
rescue => e
  warn "#{$0}: #{e}"
  exit!
end

# Write fake Rakefile for rake since Makefile isn't used
File.open(File.join(File.dirname(__FILE__), 'Rakefile'), 'w') do |f|
  f.write("task :default" + $/)
end