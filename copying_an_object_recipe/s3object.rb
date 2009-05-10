module AWS
  module S3
      
    class S3Object
      
      # Copies the current object to the target bucket.
      # target_bucket can be a bucket instance or a string containing
      # the name of the bucket.
      def copy_to_bucket(target_bucket, params = {})
        if target_bucket.is_a?(AWS::S3::Bucket)
          target_bucket = target_bucket.name
        end
        puts "#{key} => #{target_bucket}"
        begin
          S3Object.store(key, nil, target_bucket, 
                         params.merge('x-amz-copy-source' => path))
        rescue AWS::S3::PreconditionFailed          
        end
      end
      
      # Copies the current object to the target bucket
      # unless the object already exists in the target bucket
      # and they are identical.
      # target_bucket can be a bucket instance or a string containing
      # the name of the bucket.
      def copy_to_bucket_if_etags_dont_match(target_bucket, params = {})
        unless target_bucket.is_a?(AWS::S3::Bucket)
          target_bucket = AWS::S3::Bucket.find(target_bucket) 
        end
        if target_bucket[key]
          params.merge!(
            'x-amz-copy-source-if-none-match' => target_bucket[key].etag)
        end
        copy_to_bucket(target_bucket, params)
      end
      
    end

  end
end