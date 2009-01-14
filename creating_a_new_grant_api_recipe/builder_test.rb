#!/usr/bin/env ruby

require 'rubygems'
require 'builder'

b = Builder::XmlMarkup.new
puts b.Test('this is a test')