require File.expand_path(File.dirname(__FILE__) + '/lib/contacts_rails')

class ActionController::Base
  include Contacts::Rails
end
