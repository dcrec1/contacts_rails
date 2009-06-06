dir = File.dirname(__FILE__)
require File.expand_path(dir + '/spec_helper')

describe Contacts::Rails do
  include Contacts::Rails
  
  before :each do
    stub!(:action_name).and_return(@action_name = "show")
    stub!(:session).and_return(@session = {})
    stub!(:params).and_return(@params = {})
    stub!(:url_for).with(:action => @action_name).and_return(@next_url = "afsfafa")
  end
  
  context "when no token exists" do
    it "should redirect to authentication url" do
      url = Contacts::Google.authentication_url(url_for(:action => @action_name), :session => true)
      self.should_receive(:redirect_to).with(url)
      fetch_google_contacts
    end
  end
  
  context "with token in params" do
    it "should upgrade it and set it in the session" do
      @params[:token] = "fwefwefwe"
      fetch_google_contacts
      @session[:token].should eql(Contacts::Google.session_token(@params[:token]))
    end
  end
  
  context "with token in session" do    
    it "should fetch contacts to @contacts" do
      @session[:token] = "fwegfwef"
      google = mock(Object, :contacts => "fwegfwegegw")
      Contacts::Google.stub(:new).with("default", @session[:token]).and_return(google)
      fetch_google_contacts
      @contacts.should eql(google.contacts)
    end
  end
end
