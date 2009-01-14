module S3Lib
  module AclAccess
    
    def refresh_acl
      get_acl
    end    
    
    def acl(params = {})
      refresh_acl if params[:refresh]      
      @acl || get_acl
    end    
        
    private
    
    def get_acl
      @acl = Acl.new(self)
    end
    
  end
end