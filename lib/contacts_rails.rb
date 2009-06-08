require File.expand_path(File.dirname(__FILE__) + '/contacts/google')
require File.expand_path(File.dirname(__FILE__) + '/contacts/windows_live')
require File.expand_path(File.dirname(__FILE__) + '/contacts/yahoo')

module Contacts
  module Rails
    def import_live_contacts
      live = Contacts::WindowsLive.new
      post_body = request.raw_post
      if post_body.empty?
        redirect_to live.get_authentication_url
      else
        @contacts = live.contacts(post_body)
        render "import"
      end
    end
    
    def import_google_contacts
      param_token = params[:token]
      session_token = session[:token]
      if param_token.nil? and session_token.nil?    
        redirect_to Contacts::Google.authentication_url(url_for(:action => action_name), :session => true)
      else 
        session[:token] = Contacts::Google.session_token(param_token) if session_token.nil?
        @contacts = Contacts::Google.new("default", session[:token]).contacts
        render "import"
      end
    end
  end
end
