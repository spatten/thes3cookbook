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
require 'aws/s3'
include AWS::S3

class S3Syncer
  attr_reader :local_files, :files_to_upload
  
  DEFAULT_PARAMS = {:ignore_regexp => "\.svn|\.DS_Store",
                    :prefix => ''}
  
  def initialize(directory, bucket_name, params = {})
    @directory = directory
    @bucket_name = bucket_name
    @params = DEFAULT_PARAMS.merge(params)
    @params[:ignore_extensions] = @params[:ignore_extensions].split(',') if @params[:ignore_extensions]
    
    # sync_params are parameters sent to the S3Object.store in the sync method
    @sync_params = @params.dup
    @sync_params.delete(:ignore_extensions)
    @sync_params.delete(:ignore_regexp)
    @sync_params.delete(:prefix)
  end
  
  def S3Syncer.sync(directory, bucket, params = {})
    syncer = S3Syncer.new(directory, bucket, params)
    syncer.establish_connection
    syncer.get_local_files
    syncer.get_bucket
    syncer.select_files_to_upload
    syncer.sync
  end
  
  def establish_connection
    AWS::S3::Base.establish_connection!(
        :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
    )    
  end
  
  def get_local_files
    @local_files = []
    Find.find(@directory) do |file| 
      Find.prune if !@params[:ignore_regexp].empty? && file =~ /#{@params[:ignore_regexp]}/
      Fine.prune if @params[:ignore_extensions] && @params[:ignore_extensions].include?(File.extname(file))
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
      when @bucket[s3_name(file)].etag != Digest::MD5.hexdigest(File.safe_read(local_name(file)))
        true  # Upload if MD5 sums don't match
      else
        false  # the MD5 matches and it exists already, so don't upload it
      end
    end
  end
  
  def sync
    (puts "Directories are in sync"; return) if @files_to_upload.empty?
    @files_to_upload.each do |file|
      puts "#{file} ===> #{@bucket.name}:#{s3_name(file)}, params: #{@sync_params.inspect}"
      S3Object.store(s3_name(file), File.safe_read(file), @bucket_name, @sync_params.dup)      
    end
  end
  
  private 
  
  def local_name(file)
    file
  end
  
  # Remove the base directory, add a prefix and remove slash 
  # at the beginning of the string.
  def s3_name(file)
    File.join(@params[:prefix], file.sub(/\A#{@directory}/, '')).sub(/\A\//,'')
  end
  
end

USAGE = <<-USAGE
sync_directory.rb <directory to sync> <name of bucket to sync to>
USAGE

if __FILE__ == $0
  (puts USAGE; exit(0)) unless ARGV.length == 2
  S3Syncer.sync(*ARGV)
end