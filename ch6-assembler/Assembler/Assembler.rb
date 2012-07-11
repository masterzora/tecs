#!/usr/bin/env ruby
#
# The assembler for the Hack assembly.
# Written in Ruby because it seemed like a fun opportunity to try a new language

require_relative 'parser'
require_relative 'code'

asm_filename = ARGV[0]
hack_filename = asm_filename.gsub(/\.asm$/, '.hack')

File.open(hack_filename, 'w') do |hack_file|
  parse = Parser::new(asm_filename)
  symbol_table = {
    'SP' => '0',
    'LCL' => '1',
    'ARG' => '2',
    'THIS' => '3',
    'THAT' => '4',
    'R0' => '0',
    'R1' => '1',
    'R2' => '2',
    'R3' => '3',
    'R4' => '4',
    'R5' => '5',
    'R6' => '6',
    'R7' => '7',
    'R8' => '8',
    'R9' => '9',
    'R10' => '10',
    'R11' => '11',
    'R12' => '12',
    'R13' => '13',
    'R14' => '14',
    'R15' => '15',
    'SCREEN' => '16384',
    'KBD' => '24567',
  }
  line_number = 0
  while parse.more_commands?
    parse.advance
    if parse.command_type == :l_command
      symbol_table[parse.symbol] = line_number
    else
      line_number += 1
    end
  end
  parse.reset
  next_ram_address = 16
  while parse.more_commands?
    parse.advance
    type = parse.command_type
    if type == :a_command
      symbol = parse.symbol
      unless symbol.match(/^\d/)
        unless symbol_table.has_key?(symbol)
          symbol_table[symbol] = next_ram_address
          next_ram_address += 1
        end
        symbol = symbol_table[symbol]
      end
      hack_file << Code::a_instruction << "%015b" % [symbol] << "\n"
    elsif type == :c_command
      dest = parse.dest
      comp = parse.comp
      jump = parse.jump
      hack_file << Code::c_instruction << Code::comp(comp)
      hack_file << Code::dest(dest) << Code::jump(jump) << "\n"
    end
  end
end

