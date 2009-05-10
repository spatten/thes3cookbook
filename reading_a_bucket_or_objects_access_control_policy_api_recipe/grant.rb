module S3Lib
  class Grant

    attr_reader :grantee, :type, :permission

    GRANT_TYPES = {:canonical => 'CanonicalUser',
                   :email => 'AmazonCustomerByEmail', 
                   :all_s3 => 'Group', 
                   :public => 'Group'}
    GROUP_URIS = {
      'http://acs.amazonaws.com/groups/global/AuthenticatedUsers' => 
        :all_s3,
      'http://acs.amazonaws.com/groups/global/AllUsers' => :public}
    PERMISSIONS = [:read, :write, :read_acl, :write_acl, :full_control]
    
    # Create a new grant.  
    # permission is one of the PERMISSIONS defined above
    # grantee is the REXML::Document Grantee object returned by S3 
    def initialize(permission, grantee)
      @permission = permission.downcase.to_sym      
      @type = parse_type(grantee)
      @grantee = parse_grantee(grantee)
    end
    
    private
    
    def parse_type(grantee)
      type = grantee.attributes['xsi:type']
      case type
      when 'CanonicalUser': :canonical
      when 'AmazonCustomerByEmail': :email
      when 'Group'
        group_uri = grantee.elements['URI'].text
        GROUP_URIS[group_uri]
      else
        raise BadGrantTypeError        
      end
    end
    
    def parse_grantee(grantee)
      case @type
      when :canonical
        grantee.elements['ID'].text
      when :email
        grantee.elements['EmailAddress'].text
      when :all_s3: :all_s3
      when :public: :public
      else
        nil
      end
    end
    
  end
end