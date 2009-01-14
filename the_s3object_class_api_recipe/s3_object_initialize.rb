	module S3Lib
  class S3Object

		# Both metadata and value are loaded lazily if options[:lazy_load] is true
	  # This is used by Bucket.find so you don't make a request for every object in the bucket
	  # The bucket can be either a bucket object or a string containing the bucket's name
	  # The key is a string.
	  def initialize(bucket, key, options = {})
	    options.merge!(:lazy_load => false)
	    bucket = Bucket.find(bucket) unless bucket.respond_to?(:name)
	    @bucket = bucket
	    @key = key
	    @options = options
	    get_metadata unless options.delete(:lazy_load)      
	  end
  end
end