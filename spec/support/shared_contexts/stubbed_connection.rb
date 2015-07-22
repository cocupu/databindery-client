# To include this in an example group, simply call
# `include_context "stubbed connection"`
# See https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-context
RSpec.shared_context "stubbed connection", :a => :b do

  let(:stubbed_requests) { Faraday::Adapter::Test::Stubs.new }
  let(:stubbed_connection) {
    Faraday.new do |builder|
      builder.adapter :test, stubbed_requests
    end
  }
  before do
    allow(Cocupu).to receive(:connection).and_return(stubbed_connection)
  end

end