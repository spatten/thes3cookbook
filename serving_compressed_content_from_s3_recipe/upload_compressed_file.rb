#!/usr/bin/env ruby
require 'rubygems'
require 'aws/s3'
require 'stringio'
require 'zlib'

# usage: upload_compressed_file.rb <filename> <bucket>

filename, bucket = ARGV

AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
)

strio = StringIO.open('', 'w')
gz = Zlib::GzipWriter.new(strio)
gz.write(open(filename).read)
gz.close

S3Object.store(filename, strio.string, bucket, :access => :public_read, 
               "Content-Encoding" => 'gzip' ) 