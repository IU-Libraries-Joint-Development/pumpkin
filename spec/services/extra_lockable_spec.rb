require 'rails_helper'

RSpec.describe ExtraLockable do
  let(:work) { FactoryGirl.build(:scanned_resource) }

  context 'with no existing lock' do
    describe '#lock?' do
      it 'detects no existing lock' do
        expect(work.lock?(work.id)).to eq false
      end
    end
  end

  context 'with an existing lock' do
    around { |example|
      lock_info = work.lock_manager.client.lock(work.id, 10_000)
      example.run
      work.lock_manager.client.unlock(lock_info)
    }

    describe '#lock?' do
      it 'detects an existing lock' do
        expect(work.lock?(work.id)).to eq true
      end
    end
  end
end
