class AWS::S3::S3Object
  
  class << self

    alias_method :old_store, :store

    def store(key, data, bucket = nil, params = {})
      original_params = params.dup
      current_acl = acl(key, bucket) if original_params[:keep_current_acl]
      response = old_store(key, data, bucket, params)
      if original_params[:keep_current_acl]
        acl_resp = acl(key, bucket, current_acl)
      end
      response
    end

  end

end