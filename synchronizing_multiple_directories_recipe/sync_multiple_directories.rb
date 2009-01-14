#!/usr/bin/env ruby

require 'yaml'
require 'sync_directory.rb'

DEFAULT_CONFIG_FILE = "~/.sync_directory.yml"

MULTIPLE_USAGE = <<-USAGE
sync_directory.rb [s3sync_config_file.yml]
The default config file is #{DEFAULT_CONFIG_FILE}
USAGE

(puts MULTIPLE_USAGE; exit(0)) unless [0,1].include? ARGV.length

# Load in the directory info
backups = YAML.load_file(ARGV[0] || DEFAULT_CONFIG_FILE)

backups.each_value do |backup|
  puts
  backup.each do |key, value|
    puts "#{key}: #{value}"
  end
  
  directory = backup.delete(:directory)
  bucket = backup.delete(:bucket)
  params = backup
  raise "Each entry in the config file must have a :bucket and a :directory entry" unless directory && bucket
  S3Syncer.sync(directory, bucket, params)
end