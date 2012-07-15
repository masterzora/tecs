#!/usr/bin/env ruby
#
# Syntax Analyzer for Jack

require_relative 'jacktokenizer'

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
  tokenizer = JackTokenizer::new(filename)
  xml_filename = filename.sub(/\.jack$/, '2.xml')
  outfile = File.new(xml_filename, 'w')
  outfile << "<tokens>\n"
  while tokenizer.more_tokens?
    tokenizer.advance
    case tokenizer.token_type
      when :keyword
        outfile << "<keyword>%s</keyword>\n" % [tokenizer.keyword]
      when :symbol
        outfile << "<symbol>%s</symbol>\n" % [sanitize(tokenizer.symbol)]
      when :string_const
        outfile << "<stringConstant>%s</stringConstant>\n" % [sanitize(tokenizer.string_val)]
      when :int_const
        outfile << "<integerConstant>%s</integerConstant>\n" % [tokenizer.int_val]
      when :identifier
        outfile << "<identifier>%s</identifier>\n" % [tokenizer.identifier]
    end
  end
  outfile << "</tokens>\n"
  outfile.close
end
