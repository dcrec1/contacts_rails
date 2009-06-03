require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GdataContacts do
  include GdataContacts
  
  before :each do
    @session = {}
    stub!(:session).and_return(@session)
    @params = {}
    stub!(:params).and_return(@params)
    @client = GData::Client::Contacts.new
    GData::Client::Contacts.stub(:new).and_return(@client)
    @action_name = "show"
    stub!(:action_name).and_return(@action_name)
    @next_url = "afsfafa"
    stub!(:url_for).with(:action => @action_name).and_return(@next_url)
  end
  
  context "when no token exists" do
    it "should configure auth url assuming current action as next_url, security false and session true" do
      stub!(:redirect_to)
      @client.should_receive(:authsub_url).with(@next_url, false, true)
      fetch_contacts
    end
    
    it "should redirect to authsub url" do
      url = "ger gre gerg erger gege"
      @client.stub!(:authsub_url).and_return(url)
      self.should_receive(:redirect_to).with(url)
      fetch_contacts
    end
  end
  
  context "with token in params" do
    before :each do
      @params[:token] = "fwefwefwef"
      @upgrade = stub(Object)
      @client.stub(:auth_handler).and_return(stub(Object, :upgrade => @upgrade))
      @client.stub!(:authsub_token=)
      @client.stub!(:get)
    end
    
    it "should set it in the client" do
      @client.should_receive(:authsub_token=).with(@params[:token])
      fetch_contacts
    end
    
    it "should upgrade the auth handler and se it in the session" do
      fetch_contacts
      @session[:token].should eql(@upgrade)
    end
    
    it "should set the session with the upgraded auth handler" do
      @client.should_receive(:authsub_token=).with(@upgrade)
      fetch_contacts
    end
  end
  
  context "with token in session" do
    before :each do
      @session[:token] = "fwegfwefwe"
    end
    
    it "should fetch 10000 contacts to @contacts" do
      contacts = [1, 2, 3]
      @client.stub(:get).with(@client.authsub_scope + 'contacts/default/full?max-results=10000').and_return(contacts)
      fetch_contacts
      @contacts.should eql(contacts)
    end
  end
end
