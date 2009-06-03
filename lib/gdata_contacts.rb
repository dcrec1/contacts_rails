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
      @client.authsub_token = session[:token]
    end
    @contacts = @client.get("#{@client.authsub_scope}contacts/default/full?max-results=10000") unless session[:token].nil?
  end
end
