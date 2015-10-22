require 'spec_helper'

describe Cocupu::PoolIndex do
  # let(:conn)      { Cocupu.start('justin@cocupu.com', 'password', 3001, 'localhost') }
  let(:conn) { double('Cocupu::Connection')}
  let(:pool_id) { 22 }
  let(:index_name) { '8_2015-10-19_15:10:15' }

  before do
    allow(Thread).to receive(:current).and_return(cocupu_connection: conn)
  end

  describe '#update' do
    it 'tells databindery to update the index' do
      expect(conn).to receive(:put).with("/pools/#{pool_id}/indices/#{index_name}.json", body: {source: :dat})
      described_class.update(pool_id: pool_id, index_name: index_name, source: :dat)
    end
  end
end
