#!/usr/bin/env ruby

require 'rubygems'
require 's3_lib'

puts S3Lib.request(:get, '').read