#!/usr/bin/env ruby
#
# Syntax Analyzer for Jack

require_relative 'compilationengine'

def sanitize (dirty)
  dirty.gsub('&', '&amp;').gsub('"', '&quot;').gsub('<', '&lt;').gsub('>', '&gt;')
end

jack_filename = ARGV[0]
if jack_filename.match(/\.jack$/)
  files = [jack_filename]
  prefix = ''
else
  prefix = jack_filename.gsub(/\/?$/, '/')
  files = Dir.entries(jack_filename)
  files.keep_if do |filename|
    filename =~ /\.jack$/
  end
  files.collect! do |filename|
    "%s%s" % [prefix, filename]
  end
end

files.each do |filename|
  vm_filename = filename.sub(/\.jack$/, '2.vm')
  engine = CompilationEngine::new(filename, vm_filename)
  engine.compile_class
end
