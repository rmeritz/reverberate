#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'net/http'

searched_verb = ARGV.first

verb = Hash.new("---")
verb[:searched] = searched_verb

uri = URI('http://tyda.se/search/'+searched_verb)
html = Net::HTTP.get(uri)

doc = Nokogiri::HTML(html) do |config|
  config.strict.noent
end

forms = doc.css('.tyda_entry_word span')

forms = forms.each do |v|
  if v['title'] == "grundform"
    verb[:grundform] = v.children.text
  elsif v['title'] == "tempus: presens"
    verb[:presens] = v.children.text
  elsif v['title'] == "tempus: imperfekt"
    verb[:imperfekt] = v.children.text
  elsif v['title'] == "tempus: perfekt/pluskvamperfekt (har/hade)"
    verb[:prefekt] = v.children.text
  elsif v['title'] == "tempus: imperativ"
    verb[:imperativ] = v.children.text
  end
end

puts "You searched for the verb: #{verb[:searched].capitalize}."
puts "Grundform/Infinitive: #{verb[:grundform]}"
puts "Presens/Present:      #{verb[:presens]}"
puts "Imperfekt/Imperfect:  #{verb[:imperfekt]}"
puts "Prefekt/Prefect:      #{verb[:prefekt]}"
puts "Imperativ/Imperative: #{verb[:imperativ]}"
