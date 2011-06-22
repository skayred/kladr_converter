Gem::Specification.new do |s|
  s.name              = "kladr_converter"
  s.version           = "0.0.1"
  s.platform          = Gem::Platform::RUBY
  s.authors           = ["skayred"]
  s.email             = ["dg.freak@gmail.com"]
  s.homepage          = "http://github.com/skayred/kladr_converter"
  s.summary           = "KLADR to SQLite"
  s.description       = "Library that can convert KLADR.DBF and STREET.DBF to SQLite database file"
  s.rubyforge_project = s.name
 
  s.required_rubygems_version = ">= 1.3.6"
 
  # The list of files to be contained in the gem 
  s.files         = `git ls-files`.split("\n")
  # s.executables   = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  # s.extensions    = `git ls-files ext/extconf.rb`.split("\n")
 
  s.require_path = 'lib'
  s.add_dependency( 'dbf' )
  s.add_dependency( 'progressbar' )
 
  # For C extensions
  # s.extensions = "ext/extconf.rb"
end
