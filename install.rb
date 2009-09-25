yml_file = 'contacts.yml'
src = File.join(File.dirname(__FILE__) , 'lib', yml_file)
dest = File.join(RAILS_ROOT, "config", yml_file)
FileUtils.cp_r src, dest