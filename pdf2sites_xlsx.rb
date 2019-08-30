#!/usr/bin/env ruby
#encoding: utf-8

require 'bundler/inline'

#./pdf2sites_xlsx.rb -if=~/Documents/jad/ranking_ecommerce-2018.pdf -of=~/Documents/jad/sites_ecommerce.xlsx -enc=UTF-8 -f
#ARGV = ["-if=~/Documents/jad/ranking_ecommerce-2018.pdf", "-of=~/Documents/jad/sites_ecommerce.xlsx", "-enc=UTF-8", "-f"]

gemfile do
  ruby "2.3.8"
  source 'https://rubygems.org'
  gem "slop"
  gem "pdf-reader"
  gem "axlsx"
  gem "ruby-progressbar"
end


#interpreta ARGV
opts = Slop::Options.new
opts.separator '* required options'
opts.string '-if', '--input_pdf_file', '* input file (pdf)', required: true
opts.string '-of', '--output_xlsx_file', '* output file (xlsx)', required: true
opts.string '-enc', '--encoding', 'encoding (default ISO_8859_1)', default: 'ISO-8859-1'
opts.on '-f', '--force', 'force overwrite output file'
opts.separator ''
opts.separator 'other options:'
opts.on '-v', '--version' do
  puts "ruby version #{RUBY_VERSION}"
  exit
end
opts.on '-valid_encodings' do
  puts Encoding.name_list
  exit
end
opts.on '-h' do
  puts opts
  puts
  puts "accepted encondigs: UTF-8, ISO-8859-1,... (see Encoding.name_list)"
  exit
end
begin
  parser = Slop::Parser.new(opts)
  result = parser.parse(ARGV)
rescue Slop::Error => e
  puts opts
  exit
end

#validar argumentos
infile = result[:if]
oufile = result[:of]

infile.gsub!(/~/, ENV["HOME"])
oufile.gsub!(/~/, ENV["HOME"])

raise "#{infile} not found" unless File.file?(infile)
raise "#{oufile} already exists" if File.exists?(oufile) && !result[:force]
raise "Input file must be .pdf" unless infile[/\.pdf$/]
raise "Output file must be .xlsx" unless oufile[/\.xlsx$/]

#lendo
puts "Reading #{infile}..."
pdf_in = PDF::Reader.new(infile)
pg = ProgressBar.create(total: pdf_in.page_count, format: "%a %B %P%% %E %c/%C")

sites = Hash.new{|h,k| h[k] = 0}
pdf_in.pages.each do |page|
  #matches = page.text.scan(/\w+\.com(?:\.br)?/i)
  matches = page.text.scan(/\w+\.com/i)
  matches.each do |m|
    sites[m.downcase] += 1
    sites["#{m.downcase}.br"] += 1
  end
  pg.increment
end
sites = sites.sort.to_h
pg.finish
puts pg.to_s

#gerando
puts "Writing to #{oufile}..."
pg = ProgressBar.create(total: sites.size, format: "%a %B %P%% %E %c/%C")

p = Axlsx::Package.new
wb = p.workbook
item_style = wb.styles.add_style(
  :b => false, :sz => 10, :font_name => 'Arial',
  :alignment => { :horizontal => :left, :vertical => :center, :wrap_text => false}
)
header_style = wb.styles.add_style(
  :b => true, :sz => 10, :font_name => 'Arial',
  :alignment => { :horizontal => :left, :vertical => :center, :wrap_text => true}
)
max_line_size = 0
max_column_size = 0
wb.add_worksheet(:name => oufile.split("/").last[0..30]) do |sheet|
  sheet.add_row(
    %w(site #ocorrencias),
    style: header_style, height: 12
  )
  sites.each do |site, ocorrencias|
    nova_linha = [site.to_s, ocorrencias.to_s]
    sheet.add_row nova_linha, style: item_style, height: 12, types: [:string] * nova_linha.size
    max_column_size = nova_linha.map(&:size).max if nova_linha.map(&:size).max > max_column_size
    max_line_size = nova_linha.size if nova_linha.size > max_line_size
    pg.increment
  end
  col_widths = [max_column_size] * max_line_size
  sheet.column_widths *col_widths
  sheet.sheet_view.pane do |pane|
    pane.top_left_cell = "A2"
    pane.state = :frozen_split
    pane.y_split = 1
    pane.x_split = 0
    pane.active_pane = :bottom_right
  end
end
p.serialize(oufile)
pg.finish
puts pg.to_s

