module GData
  attr_reader :name, :email

  class Contact
    def initialize(opts)
      @email = opts[:email]
      @name = opts[:name]
    end
    
    def to_json
      "{'email' => '#{@email}', 'name' => '#{@name}'}"
    end
  end
end

module GdataContacts
  def fetch_contacts
    @client = GData::Client::Contacts.new

    if params[:token].nil? and session[:token].nil?
      next_url = url_for :action => action_name
      secure = false
      redirect_to @client.authsub_url(next_url, secure, true)
    elsif params[:token] and session[:token].nil?
      @client.authsub_token = params[:token]
      session[:token] = @client.auth_handler.upgrade
    end
    @client.authsub_token = session[:token] if session[:token]

    unless session[:token].nil?
      @contacts = []
      @client.get("#{@client.authsub_scope}contacts/default/full?max-results=10000").to_xml.elements.each('entry') do |entry|
        opts = {:name => entry.elements['title'].text}
        entry.elements.each('gd:email') do |email|
          opts[:email] = email.attribute('address').value if email.attribute('primary')
        end
        @contacts.push GData::Contact.new(opts)
      end
    end
  end
end
