DIR = File.dirname(__FILE__)
require File.expand_path(DIR + '/spec_helper')

describe Contacts::Imports do
  include Contacts::Imports
  
  before :each do
    stub!(:action_name).and_return(@action_name = "show")
    stub!(:params).and_return(@params = {})
    stub!(:url_for).with(:action => @action_name).and_return(@next_url = "afsfafa")
    stub!(:request).and_return(@request = mock(Object))
    stub!(:render)
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
      before :each do
        @params[:token] = "f2fwefwe"
        @google = mock(Object, :contacts => "fwegfwegegw")
        Contacts::Google.stub(:new).with("default", @params[:token]).and_return(@google)
      end
      
      it "should fetch contacts to @contacts" do
        import_google_contacts
        @contacts.should eql(@google.contacts)
      end
      
      it "should render import" do
        self.should_receive(:render).with("import")
        import_google_contacts
      end
    end
  end
  
  context "importing Live contacts" do
    before :each do
      file = YAML.load_file(DIR + '/feeds/contacts.yml')
      YAML.stub(:load_file).and_return(file)
      @wl = Contacts::WindowsLive.new
    end
  
    it "should redirect to Live authentication when no POST body exists" do
      @request.stub!(:raw_post).and_return("")
      self.should_receive(:redirect_to).with(@wl.get_authentication_url)
      import_live_contacts
    end
    
    context "when POST body exists" do
      before :each do
        Contacts::WindowsLive.stub!(:new).and_return(@wl)
        @request.stub!(:raw_post).and_return(@raw_post = "fwefwefw")
        @wl.stub!(:contacts)
        stub!(:render)
      end
    
      it "should fetch contacts to @contacts" do
        @wl.should_receive(:contacts).with(@raw_post).and_return(contacts = [1, 2, 3])
        import_live_contacts
        @contacts.should eql(contacts)
      end
      
      it "should render import" do
        self.should_receive(:render).with("import")
        import_live_contacts
      end
    end
  end
  
  context "importing from a CVS file" do
    def value(lines, line_number, position)
      lines[line_number].split(",")[position].strip
    end
    
    def file
      File.open(DIR + '/contacts.cvs')
    end
  
    it "should read a file passed as cvs_file and return a list of contacts to @contacts" do
      @params[:cvs_file] = file
      import_cvs_contacts
      lines = file.each_line.to_a
      i = 1
      @contacts.each do |contact|
        contact[0].should eql(value(lines, i, 1))
        contact[1].should eql(value(lines, i, 0))
        i = i + 1
      end
    end
    
    it "should render import" do
      @params[:cvs_file] = file
      self.should_receive(:render).with("import")
      import_cvs_contacts
    end
  end
end
