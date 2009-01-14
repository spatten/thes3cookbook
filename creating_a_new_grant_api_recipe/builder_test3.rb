#!/usr/bin/env ruby

require 'rubygems'
require 'builder'

b = Builder::XmlMarkup.new
xml = b.Name(:nice_guy => true) do
  b.first('Scott')
  b.last('Patten')
end

puts xml