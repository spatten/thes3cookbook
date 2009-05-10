#!/usr/bin/env ruby

class File
  
  # Reads both symlinks and normal files correctly.  
  # This probably breaks horribly on Windows
  def self.safe_read(file)
    File.symlink?(file) ? File.readlink(file) : File.read(file)
  end
end

require 'find'
require 'rubygems'
require 's3lib'
include S3Lib

class S3Syncer
  attr_reader :local_files, :files_to_upload
  
  def initialize(directory, bucket_name)
    @directory = directory
    @bucket_name = bucket_name
  end
  
  def S3Syncer.sync(directory, bucket)
    syncer = S3Syncer.new(directory, bucket)
    syncer.get_local_files
    syncer.get_bucket
    syncer.select_files_to_upload
    syncer.sync
  end
  
  def get_local_files
    @local_files = []
    Find.find(@directory) do |file| 
      @local_files.push(file)
    end
  end 
  
  def get_bucket
    Bucket.create(@bucket_name)
    @bucket = Bucket.find(@bucket_name) 
  end
  
  # Files should be uploaded if 
  #   The file doesn't exist in the bucket
  #      OR
  #   The MD5 hashes don't match
  def select_files_to_upload
    @files_to_upload = @local_files.select do |file|                 
      case
      when File.directory?(local_name(file))
        false # Don't upload directories
      when !@bucket[s3_name(file)]
        true  # Upload if file does not exist on S3
      when @bucket[s3_name(file)].etag != 
          Digest::MD5.hexdigest(File.safe_read(local_name(file)))
        true  # Upload if MD5 sums don't match
      else
        false  # the MD5 matches and it exists already, so don't upload it
      end
    end
  end
  
  def sync
    (puts "Directories are in sync"; return) if @files_to_upload.empty?

    @files_to_upload.each do |file|
      puts "#{file} ===> #{@bucket.name}:#{s3_name(file)}"
      S3Object.create(@bucket_name, s3_name(file), File.safe_read(file))
    end
  end
  
  private 
  
  def local_name(file)
    file
  end
  
  # Remove the directory name and first forward slash.
  def s3_name(file)
    file.sub(/\A#{@directory}/, '').sub(/\A\//,'')
  end
  
end

USAGE = <<-USAGE
sync_directory.rb <directory to sync> <name of bucket to sync to>
USAGE

# Run this part if you're loading the file directly.  
# It won't be run if, for example, you're requiring the file.
if __FILE__ == $0 
  (puts USAGE; exit(0)) unless ARGV.length == 2  
  S3Syncer.sync(*ARGV)
end