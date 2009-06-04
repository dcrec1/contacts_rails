require File.expand_path(File.dirname(__FILE__) + '/lib/gdata_contacts')

class ActionController::Base
  include GdataContacts
end
