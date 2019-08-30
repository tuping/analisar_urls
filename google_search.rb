require 'bundler/inline'

gemfile do
  ruby "2.3.8"
  source 'https://rubygems.org'
  gem "google_search_results"
  gem "pry"
  gem "pry-nav"
  gem "ruby-progressbar"
end

require "yaml"
api_key = YAML.load_file("config.yml")["api_key"]
#https://console.developers.google.com/apis/credentials?project=personal-1558548870901

require 'google_search_results'
#client = GoogleSearchResults.new(q: "coffee", serp_api_key: api_key )
client = GoogleSearchResults.new(q: "coffee")
hash_results = client.get_hash