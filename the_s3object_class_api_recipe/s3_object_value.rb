module S3Lib

  class S3Object

		def value(params = {})
      refresh if params[:refresh]
      @value || get_value
    end

    def refresh
      get_value
    end

    def get_value
      request = S3Object.object_request(:get, url, @options)
      @metadata = request.meta      
      @value = request.read
    end

	end
end