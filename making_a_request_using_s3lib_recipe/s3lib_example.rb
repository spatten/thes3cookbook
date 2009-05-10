#!/usr/bin/env ruby

require 'rubygems'
require 's3lib'

puts S3Lib.request(:get, '').read