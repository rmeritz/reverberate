#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'net/http'

verb = ARGV.first

uri = URI('http://tyda.se/search/'+verb)
html = Net::HTTP.get(uri)

doc = Nokogiri::HTML(html) do |config|
  config.strict.noent
end

forms = doc.css('.tyda_entry_word span')

#verbs = {
#  :grundform =>,
#  :presens =>,
#  :imperfekt =>,
#  :perfekt =>,
#  :imperativ =>,
#}

#pp verbs
p forms.to_s
