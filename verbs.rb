#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'nokogiri'
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
    verb[:preteritum] = v.children.text
  elsif v['title'] == "tempus: perfekt/pluskvamperfekt (har/hade)"
    verb[:prefekt] = v.children.text
  elsif v['title'] == "tempus: imperativ"
    verb[:imperativ] = v.children.text
  end
end

def grupp1?(verb_hash)
  (verb_hash[:grundform] =~ /a$/) &&
    (verb_hash[:grundform]+"r"  == verb_hash[:presens]) &&
    (verb_hash[:grundform]+"de" == verb_hash[:preteritum]) &&
    (verb_hash[:grundform]+"t"  == verb_hash[:prefekt]) &&
    (if verb_hash[:imperativ] != "---"
       verb_hash[:grundform]+"!" == verb_hash[:imperativ]
     end)
end

if grupp1?(verb)
  verb[:grupp] = "1 - Verb som sluttar på -a"
elsif grupp2a?(verb)
  verb[:grupp] = "2a - Verb som slutar på en konsonant ljud"
elsif grupp2b?(verb)
  verb[:grupp] = "2b - Verb som slutar på en tonlösa konsonant"
elsif grupp3?(verb)
  verb[:grupp] = "3 - Verb som slutar på en vokal annan än -a"
elsif grupp4?(verb)
  verb[:grupp] = "4 - Verb som slutar på en vokal annan än -a"
else
  verb[:grupp] = "5 - Orgelbunda Verb"
end

puts "You searched for the verb: #{verb[:searched].capitalize}."
puts "Grundform/Infinitive: #{verb[:grundform]}"
puts "Presens/Present:      #{verb[:presens]}"
puts "Preteritum/Past:      #{verb[:preteritum]}"
puts "Prefekt/Prefect:      #{verb[:prefekt]}"
puts "Imperativ/Imperative: #{verb[:imperativ]}"
puts "Verb Grupp #{verb[:grupp]}"
