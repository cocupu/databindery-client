require 'cocupu'
require 'byebug'
require 'faraday'
require 'vcr'

# require 'fakeweb'

Dir["./spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # so we can use :vcr rather than :vcr => true;
  # in RSpec 3 this will no longer be necessary.
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # config.before(:suite) do
  #   FakeWeb.allow_net_connect = false
  # end
  #
  # config.after(:suite) do
  #   FakeWeb.allow_net_connect = true
  # end
end

VCR.configure do |config|
  config.cassette_library_dir = "vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
  config.configure_rspec_metadata!
  # config.debug_logger = File.open('vcr_debug.txt', 'w')
end

def fixture_file(path)
  File.open(fixture_file_path(path))
end

def fixture_file_path(path)
  File.join('spec/fixtures', path)
end
