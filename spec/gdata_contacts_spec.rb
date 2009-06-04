dir = File.dirname(__FILE__)
require File.expand_path(dir + '/spec_helper')

describe GData::Contact do
  it "should have a name" do
    name = "Diego Carrion"
    GData::Contact.new(:name => name).name.should eql(name)  
  end
  
  it "should have an email" do
    email = "rails@ownage.com"
    GData::Contact.new(:email => email).email.should eql(email)  
  end
end

describe GdataContacts do
  include GdataContacts
  
  before :each do
    stub!(:session).and_return(@session = {})
    stub!(:params).and_return(@params = {})
    stub!(:action_name).and_return(@action_name = "show")
    stub!(:url_for).with(:action => @action_name).and_return(@next_url = "afsfafa")
    @client = mock(GData::Client::Contacts, :null_object => true)
    GData::Client::Contacts.stub(:new).and_return(@client)
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
    end
    
    it "should set it in the client" do
      @client.should_receive(:authsub_token=).with(@params[:token])
      fetch_contacts
    end
    
    it "should upgrade the auth handler and set it in the session" do
      fetch_contacts
      @session[:token].should eql(@upgrade)
    end
  end
  
  context "with token in session" do
    before :each do
      @token = "fwegfwef"
      @session[:token] = @token
    end
    
    it "should set it as the client authsub_token" do
      @client.should_receive(:authsub_token=).with(@token)
      fetch_contacts
    end
    
    it "should fetch 10000 contacts to @contacts" do
      gdata = mock(Object, :to_xml => REXML::Document.new(File.open(dir + "/data.xml")).root)
      @client.stub(:get).with(@client.authsub_scope + 'contacts/default/full?max-results=10000').and_return(gdata)
      fetch_contacts
      contacts = []
      [{:email=>"jvhlf@yahoo.com.br", :name=>nil}, 
       {:email=>"sammer.valgas@gmail.com", :name=>nil}, 
       {:name=>"Naat"}].each { |map| contacts << GData::Contact.new(map) }
      @contacts.each { |contact| contact.to_json.should eql(contacts[@contacts.index contact].to_json) }
    end
  end
end
