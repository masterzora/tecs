#!/usr/bin/env ruby
#
# The VMtranslator for the Jack VM

require_relative 'parser'
require_relative 'codewriter'

vm_filename = ARGV[0]
if vm_filename.match(/\.vm$/)
  asm_filename = vm_filename.sub(/\.vm$/, '.asm')
  files = [vm_filename]
else
  asm_filename = "%s/%s.asm" % [vm_filename, vm_filename.sub(/^.*\//, '')]
  files = Dir.entries(vm_filename)
  files.keep_if do |filename|
    filename =~ /\.vm$/
  end
  files.collect! do |filename|
    "%s/%s" % [vm_filename, filename]
  end
end

writer = CodeWriter::new(asm_filename)
writer.write_init
files.each do |filename|
  parser = Parser::new(filename)
  writer.set_filename(filename.gsub(/(^.*\/)|(\.vm$)/, ''))
  while parser.more_commands?
    parser.advance
    case parser.command_type
      when :c_arithmetic
        writer.write_arithmetic(parser.arg1)
      when :c_push
        writer.write_push_pop('push', parser.arg1, parser.arg2)
      when :c_pop
        writer.write_push_pop('pop', parser.arg1, parser.arg2)
      when :c_label
        writer.write_label(parser.arg1)
      when :c_goto
        writer.write_goto(parser.arg1)
      when :c_if
        writer.write_if(parser.arg1)
      when :c_call
        writer.write_call(parser.arg1, parser.arg2)
      when :c_return
        writer.write_return
      when :c_function
        writer.write_function(parser.arg1, parser.arg2.to_i)
    end
  end
end
writer.close

