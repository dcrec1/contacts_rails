dir = File.dirname(__FILE__)
require File.expand_path(dir + '/spec_helper')

describe Contacts::Rails do
  include Contacts::Rails
  
  before :each do
    stub!(:action_name).and_return(@action_name = "show")
    stub!(:session).and_return(@session = {})
    stub!(:params).and_return(@params = {})
    stub!(:url_for).with(:action => @action_name).and_return(@next_url = "afsfafa")
    stub!(:request).and_return(@request = mock(Object))
  end
  
  context "importing Google contacts" do
    context "when no token exists" do
      it "should redirect to authentication url" do
        url = Contacts::Google.authentication_url(url_for(:action => @action_name), :session => true)
        self.should_receive(:redirect_to).with(url)
        import_google_contacts
      end
    end
    
    context "with token in params" do
      it "should upgrade it and set it in the session" do
        @params[:token] = "fwefwefwe"
        import_google_contacts
        @session[:token].should eql(Contacts::Google.session_token(@params[:token]))
      end
    end
    
    context "with token in session" do    
      it "should fetch contacts to @contacts" do
        @session[:token] = "fwegfwef"
        google = mock(Object, :contacts => "fwegfwegegw")
        Contacts::Google.stub(:new).with("default", @session[:token]).and_return(google)
        import_google_contacts
        @contacts.should eql(google.contacts)
      end
    end
  end
  
  context "importing Live contacts" do
    before :each do
      file = YAML.load_file(File.dirname(__FILE__) + '/feeds/contacts.yml')
      YAML.stub(:load_file).and_return(file)
      @wl = Contacts::WindowsLive.new
    end
  
    it "should redirect to Live authentication when no POST body exists" do
      @request.stub!(:raw_post).and_return("")
      self.should_receive(:redirect_to).with(@wl.get_authentication_url)
      import_live_contacts
    end
    
    it "should fetch contacts to @contacts when POST body exists" do
      Contacts::WindowsLive.stub!(:new).and_return(@wl)
      @request.stub!(:raw_post).and_return(raw_post = "fwefwefw")
      @wl.should_receive(:contacts).with(raw_post).and_return(contacts = [1, 2, 3])
      import_live_contacts
      @contacts.should eql(contacts)
    end
  end
end
