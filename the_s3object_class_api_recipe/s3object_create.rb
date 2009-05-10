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
      options.merge!({:body => value || "", 
                      'content-type' => DEFAULT_CONTENT_TYPE})
      response = S3Object.object_request(:put, S3Object.url(bucket, key), 
                                         options)
      response.status[0] == "200" ? 
         S3Object.new(bucket, key, options) : false
    end

    # bucket can be either a Bucket object or a string containing 
    # the bucket's name
    def self.url(bucket, key)
      bucket_name = bucket.respond_to?(:name) ? bucket.name : bucket
      File.join(bucket_name, key)
    end     
    
    def url
      S3Object.url(@bucket.name, @key)
    end

	end
end