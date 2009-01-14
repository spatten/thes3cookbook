module S3Lib

  class S3Object

    DEFAULT_CONTENT_TYPE = 'binary/octect-stream'

    attr_reader :key, :bucket

    # This is just an alias for S3Object.new
    def self.find(bucket, key, options = {})
      S3Object.new(bucket, key, options)
    end

    def self.create(bucket, key, value = "", options = {})    
			# translate from :access to 'x-amz-acl'
	    params['x-amz-acl'] = params.delete(:access) if params[:access]
      options.merge!({:body => value || "", 'content-type' => DEFAULT_CONTENT_TYPE})
      response = S3Object.object_request(:put, S3Object.url(bucket, key), options)
      response.status[0] == "200" ? S3Object.new(bucket, key, options) : false
    end

    # Delete an object given the object's bucket and key.
    # No error will be raised if the object does not exist.
    def self.delete(bucket, key, options = {})
      S3Object.object_request(:delete, S3Object.url(bucket, key), options)
    end

    def delete
      S3Object.delete(@bucket, @key, @options)
    end

    def self.value(bucket, key, options = {})
      request = S3Object.object_request(:get, S3Object.url(bucket, key), options)      
      request.read
    end

    # Both metadata and value are loaded lazily if options[:lazy_load] is true
    # This is used by Bucket.find so you don't make a request for every object in the bucket
    # The bucket can be either a bucket object or a string containing the bucket's name
    # The key is a string.
    def initialize(bucket, key, options = {})
      bucket = Bucket.find(bucket) unless bucket.respond_to?(:name)
      @bucket = bucket
      @key = key
      @options = options
      get_metadata unless options[:lazy_load]
    end  

    # bucket can be either a Bucket object or a string containing the bucket's name
    def self.url(bucket, key)
      bucket_name = bucket.respond_to?(:name) ? bucket.name : bucket
      File.join(bucket_name, key)
    end     

    def url
      S3Object.url(@bucket.name, @key)
    end 

    def metadata
      @metadata || get_metadata
    end

    def value(params = {})
      refresh if params[:refresh]
      @value || get_value
    end

    def value=(value)
      S3Object.create(@bucket, @key, value, @options)
      @value = value
      refresh_metadata
    end

    def refresh
      get_value
    end

    def refresh_metadata
      get_metadata
    end

    def content_type
      metadata["content-type"]
    end

    def etag
      metadata["etag"]
    end

    def length
      metadata["content-length"].to_i
    end

    private

    def self.object_request(verb, url, options = {})
      begin
        options.delete(:lazy_load)
        response = S3Lib.request(verb, url, options)
      rescue S3Lib::S3ResponseError => error
        case error.amazon_error_type
        when 'NoSuchBucket': raise S3Lib::BucketNotFoundError.new("The bucket '#{bucket}' does not exist.", error.io, error.s3requester)
        when 'NotSignedUp': raise S3Lib::NotYourBucketError.new("The bucket '#{bucket}' is owned by somebody else", error.io, error.s3requester)
        when 'AccessDenied': raise S3Lib::NotYourBucketError.new("The bucket '#{bucket}' is owned by someone else.", error.io, error.s3requester)
        when 'MissingContentLength': raise S3Lib::NoContentError.new("You must provide a value to put in the object.\nUsage: S3Lib::S3Object.create(bucket, key, value, options)", error.io, error.s3requester)          
        else # Re-raise the error if it's not one of the above
          raise
        end
      end
      response
    end

    def get_metadata
      request = S3Object.object_request(:head, url, @options)
      @metadata = request.meta
    end

    def get_value
      request = S3Object.object_request(:get, url, @options)
      @metadata = request.meta      
      @value = request.read
    end

  end

end