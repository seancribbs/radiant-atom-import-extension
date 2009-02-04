# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/vendor/atom/lib")
class AtomImportExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/atom_import"
  
  def activate
  end
end
