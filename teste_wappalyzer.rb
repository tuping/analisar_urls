require 'bundler/inline'

gemfile do
  ruby "2.3.8"
  source 'https://rubygems.org'
end

require "timeout"
require "open3"

saida = ""
begin
  Timeout.timeout(30) do
    #stdin, stdout, stderr, wait_thr = Open3.popen3("wappalyzer", "https://www.decathlon.com")
    stdin, stdout, stderr, wait_thr = Open3.popen3("wappalyzer", "https://www.saraiva.com.br")
    status = wait_thr.value
    saida = stdout.read
    stdin.close
    stdout.close
    stderr.close
  end
end


