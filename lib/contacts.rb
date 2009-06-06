module Contacts
  class FetchingError < RuntimeError
    attr_reader :response
    
    def initialize(response)
      @response = response
      super "expected HTTPSuccess, got #{response.class} (#{response.code} #{response.message})"
    end
  end
  
  def Contacts.inside_rails_app?
    rails = defined?(RAILS_ROOT)
    !rails.nil?
  end

end
