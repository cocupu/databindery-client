require 'cocupu'

require 'fakeweb'

Dir["./spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

  config.before(:suite) do
    FakeWeb.allow_net_connect = false
  end

  config.after(:suite) do
    FakeWeb.allow_net_connect = true
  end
end
