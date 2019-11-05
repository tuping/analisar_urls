#!/usr/bin/env ruby
#encoding: utf-8

#instalar o wappalyzer: npm i -g wappalyzer
#atualizar pacotes: npm update -g

require 'bundler/inline'
require_relative 'extrator'
require_relative 'analisador'
require "timeout"
require "open3"

#./analisar_urls.rb -if=~/Documents/jad/sites_ecommerce.xlsx -of=~/Documents/jad/sites_ecommerce_out.xlsx -enc=UTF-8 -f
# o arquivo deve ter uma coluna "cliente" e uma coluna "site"

gemfile do
  ruby "2.6.3"
  source 'https://rubygems.org'
  gem "slop"
  gem "pry"
  gem "pry-nav"
  gem "roo"
  gem "axlsx"
  gem "ruby-progressbar"
end

#interpreta ARGV
opts = Slop::Options.new
opts.separator '* required options'
opts.string '-if', '--input_xlsx_file', '* input file (xlsx)', required: true
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
raise "Both files (input and output) must be .xlsx" unless infile[/\.xlsx$/] && oufile[/\.xlsx$/]

#processa in, gera out
xlsx_in = Roo::Spreadsheet.open(infile, encoding: Encoding.find(result[:enc]))
pg = ProgressBar.create(total: xlsx_in.sheet(0).last_row-1, format: "%a %B %P%% %E %c/%C")

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
    %w(#linha_original cliente site url application confidence category),
    style: header_style, height: 12
  )
  num_linha = 2
  xlsx_in.sheet(0).parse(headers: true)[1..-1].each do |row|
    linha = Extrator.new(row).to_hash
    cliente = linha[:cliente].to_s
    site = linha[:site].to_s.gsub(/^https?:\/\//, "")
    site.gsub!(/^www\./, "")
    unless site.empty? then
      urls = ["http://www.#{site}", "https://www.#{site}", "http://#{site}", "https://#{site}"]
      success = false
      urls.each do |url|
        unless success then
          puts ".... analyzing #{url} ...."

          saida = ""
          erro = ""
          begin
            Timeout.timeout(30) do
              stdin, stdout, stderr, wait_thr = Open3.popen3("wappalyzer", url)
              status = wait_thr.value
              saida = stdout.read
              stdin.close
              stdout.close
              stderr.close
            end
          rescue Exception => e
            saida = ""
            erro = e.message.to_s
          end
          unless saida.empty? then
            a = Analisador.new(saida)
            begin
              aplicacoes = a.convert_hash_to_array
              success = a.success?
            rescue Exception => e
              aplicacoes = [[url, "", saida.to_s, e.message.to_s]]
              success = false
            end
          else
            aplicacoes = [[url, "", saida.to_s, erro]]
          end
          aplicacoes.each do |a|
            nova_linha = [num_linha, cliente, site, a].flatten
            sheet.add_row nova_linha, style: item_style, height: 12, types: [:string] * nova_linha.size
            max_column_size = nova_linha.map(&:size).max if nova_linha.map(&:size).max > max_column_size
            max_line_size = nova_linha.size if nova_linha.size > max_line_size
          end
        end
      end
    else
      nova_linha = [num_linha, cliente, site, "N/D", "N/D", "N/D"]
      sheet.add_row nova_linha, style: item_style, height: 12, types: [:string] * nova_linha.size
    end
    num_linha += 1
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

=begin
para debug use
puts "type 'exit' to continue"
binding.pry #type exit to continue
=end
