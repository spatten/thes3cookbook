module S3Lib
  class Grant
    attr_reader :acl, :grantee, :type, :permission
    GRANT_TYPES = {:canonical => 'CanonicalUser',
                   :email => 'AmazonCustomerByEmail', 
                   :all_s3 => 'Group', 
                   :public => 'Group'}
    GROUP_URIS = {
      'http://acs.amazonaws.com/groups/global/AuthenticatedUsers' => 
         :all_s3,
      'http://acs.amazonaws.com/groups/global/AllUsers' => :public}
    PERMISSIONS = [:read, :write, :read_acl, :write_acl, :full_control]
    NAMESPACE_URI = 'http://www.w3.org/2001/XMLSchema-instance'
    
    # Create a new grant.  
    # permission is one of the PERMISSIONS defined above
    # grantee can be either a REXML::Document object or a Hash
    # The grantee Hash should look like this:
    # {:type => :canonical|:email|:all_s3|:public, 
    #  :grantee => canonical_user_id | email_address}
    #
    # The :grantee element of the hash is only required (and meaningful) 
    # for :canonical and :email Grants
    def initialize(permission, grantee)
      @type = parse_type(grantee)
      @permission = parse_permission(permission)
      @grantee = parse_grantee(grantee)
    end
    
    def to_xml
      builder = Builder::XmlMarkup.new(:indent => 2)
      xml = builder.Grant do
        builder.Grantee('xmlns:xsi' => NAMESPACE_URI, 
                        'xsi:type' => GRANT_TYPES[@type]) do
          case type
          when :canonical: builder.ID(@grantee)
          when :email: builder.EmailAddress(@grantee)
          when :all_s3: builder.URI(group_uri_from_group_type(:all_s3))
          when :public: builder.URI(group_uri_from_group_type(:public))
          else
          end
        end
        builder.Permission(@permission.to_s.upcase)
      end
    end
    
    private
    
    # permission can either be the String provided by S3
    # or a symbol (see the PERMISSIONS array for allowed values)
    def parse_permission(permission)
      if permission.is_a?(String)
        permission.downcase.to_sym
      else
        permission
      end
    end
    
    def parse_type(grantee)
      if grantee.is_a?(Hash)
        grantee[:type]
      else # Assume it's a REXML::Doc object
        type = grantee.attributes['xsi:type']
        case type
        when 'CanonicalUser': :canonical
        when 'AmazonCustomerByEmail': :email
        when 'Group'
          group_uri = grantee.elements['URI'].text
          group_type_from_group_uri(group_uri)
        else
          raise BadGrantTypeError
        end
      end
    end
    
    def parse_grantee(grantee)
      if grantee.is_a?(Hash) 
        if [:canonical, :email].include?(@type)
          grantee[:grantee]
        else
          @type
        end
      else # it's a REXML::Doc object
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
    
    def group_type_from_group_uri(group_uri)
      GROUP_URIS[group_uri]
    end
    
    def group_uri_from_group_type(group_type)
      GROUP_URIS.invert[group_type]
    end
    
  end
end