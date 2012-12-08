version = File.read(File.expand_path("../VERSION",__FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'cocupu'
  s.version     = version
  s.summary     = 'A client for the Cocupu server'
  s.description = 'Cocupu is a platform for collecting, curating and publishing your data.  This client allows you to interface with that data.'

  s.required_ruby_version     = '>= 1.9.3'
  s.required_rubygems_version = ">= 1.8.11"

  s.author   = 'Justin Coyne'
  s.email    = 'justin@cocupu.com'
  s.homepage = 'http://cocupu.com'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('httmultiparty', '0.3.8')
  s.add_development_dependency('fakeweb', '1.3.0')
  s.add_development_dependency('rspec')

end
