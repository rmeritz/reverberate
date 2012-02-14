#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$KCODE = "UTF-8"

require 'rubygems'
require 'nokogiri'
require 'net/http'

searched_verb = ARGV.first

verb = Hash.new("---")
verb[:searched] = searched_verb

uri = URI(URI.escape('http://tyda.se/search/'+searched_verb))
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

puts "You searched for the verb: #{verb[:searched].capitalize}."
puts "Grundform/Infinitive: #{verb[:grundform]}"
puts "Presens/Present:      #{verb[:presens]}"
puts "Preteritum/Past:      #{verb[:preteritum]}"
puts "Prefekt/Prefect:      #{verb[:prefekt]}"
puts "Imperativ/Imperative: #{verb[:imperativ]}"

def base(verb_hash)
  verb_hash[:imperativ].chomp("!")
end

def grupp1?(verb_hash)
  (verb_hash[:grundform] =~ /a$/) &&
    (verb_hash[:grundform]+"r"  == verb_hash[:presens]) &&
    (verb_hash[:grundform]+"de" == verb_hash[:preteritum]) &&
    (verb_hash[:grundform]+"t"  == verb_hash[:prefekt]) &&
    (verb_hash[:grundform]+"!"  == verb_hash[:imperativ])
end

def grupp2?(verb_hash)
  ((base(verb_hash)+"er" || base(verb_hash)+"r") == verb_hash[:presens]) &&
    (base(verb_hash)+"a" == verb_hash[:grundform]) &&
    (base(verb_hash)+"t" == verb_hash[:prefekt])
end

def grupp2b?(verb_hash)
  (base(verb_hash) =~ /[cfpstk]$/) &&
    (base(verb_hash)+"te" == verb_hash[:preteritum])
end

def grupp2a?(verb_hash)
  (verb_hash[:imperativ].chomp("!")+"de" == verb_hash[:preteritum])
end

def grupp3?(verb_hash)
  (base(verb_hash) =~ /[eiouäåö]$/) &&
    (base(verb_hash) == verb_hash[:grundform]) &&
    (base(verb_hash)+"r" == verb_hash[:presens]) &&
    (base(verb_hash)+"dde" == verb_hash[:preteritum]) &&
    (verb_hash[:grundform]+"tt"  == verb_hash[:prefekt])
end

def grupp4vowels(verb_hash)
  begin
    p = /([bcdfghjklmnpqrstvwxz]+)([aeiouäåöy])([bcdfghjklmnpqrstvwxz]+)/
    if p.match(base(verb_hash))
      head = $1
      first_vowel = $2
      tail = $3
      (base(verb_hash) == ((verb_hash[:presens]).chomp!("er"))) &&
        ((base(verb_hash)) == ((verb_hash[:grundform]).chomp!("a"))) &&
        if p.match(verb_hash[:preteritum]) &&
            head == $1 && tail == $3
        end
      second_vowel = $2
      if p.match((verb_hash[:prefekt]).chomp!("it")) &&
          head == $1 && tail == $3
      end
      third_vowel = $2
    end
    first_vowel + "-" + second_vowel + "-" + third_vowel
  rescue
    false
  end
end

def grupp(verb_hash)
  if grupp1?(verb_hash)
    "1 - Verb som sluttar på -a"
  elsif grupp2?(verb_hash)
    if grupp2b?(verb_hash)
      "2b - Verb som slutar på en tonlösa konsonant"
    elsif grupp2a?(verb_hash)
      "2a - Verb som slutar på en konsonant ljud"
    end
  elsif grupp3?(verb_hash)
    "3 - Verb som slutar på en vokal annan än -a"
  elsif vowels = grupp4vowels(verb_hash)
    "4 - I de starka verben ändra vokalen i stammen " + vowels
  else
    "5 - Orgelbunda Verb"
  end
end

verb[:grupp] = grupp(verb)

puts "Verb Grupp #{verb[:grupp]}"
