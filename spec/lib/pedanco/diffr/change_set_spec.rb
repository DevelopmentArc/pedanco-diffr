require 'spec_helper'

describe Pedanco::Diffr::ChangeSet do

  let(:change_set) { Pedanco::Diffr::ChangeSet.new }

  describe '#initialize' do
    it 'parses change hash' do
      set = described_class.new(foo: %w(bar baz), biff: [nil, 'hello'])
      expect(set.changed?([:foo, 'biff'])).to be_truthy
      expect(set.get_change(:foo).current).to eq 'bar'
    end
  end

  describe '#add_change' do
    it 'adds a new change' do
      change_set.add_change(:name, 'foo', 'bar')
      expect(change_set.get_change(:name)).to_not be_nil
      expect(change_set.get_change(:name).current).to eq 'foo'
      expect(change_set.get_change(:name).previous).to eq 'bar'
    end

    it 'allows nil for current' do
      change_set.add_change(:name, nil, 'bar')
      expect(change_set.get_change(:name)).to_not be_nil
    end

    it 'allows nil for previous' do
      change_set.add_change(:name, 'foo', nil)
      expect(change_set.get_change(:name)).to_not be_nil
    end

    it 'defaults previous to nil' do
      change_set.add_change(:name, 'foo')
      expect(change_set.get_change(:name)).to_not be_nil
    end

    it 'requires a name' do
      expect do
        change_set.add_change(nil, 'foo', 'bar')
      end.to raise_error
    end

    it 'requires current as an argument' do
      expect do
        change_set.add_change(:name)
      end.to raise_error
    end

    it 'overrides a change' do
      change_set.add_change(:name, 'foo', 'bar')
      change_set.add_change(:name, 'bar', 'baz')
      expect(change_set.get_change(:name).current).to eq 'bar'
    end
  end

  describe '#remove_change' do
    before(:each) { change_set.add_change(:name, 'foo') }

    it 'deletes an existing change' do
      change_set.remove_change(:name)
      expect(change_set.changed?(:name)).to be_falsey
    end

    it 'returns truthy when removing an existing change' do
      expect(change_set.remove_change(:name)).to be_truthy
    end

    it 'returns falsey when removing an non-existing change' do
      expect(change_set.remove_change(:foo)).to be_falsey
    end
  end

  describe '#changed?' do
    before(:each) do
      change_set.add_change(:name, 'foo')
      change_set.add_change(:age, 12)
      change_set.add_change(:email, 'bar@biz.com')
    end

    it 'finds a single change' do
      expect(change_set.changed?(:name)).to eq true
    end

    it 'matches mutliple changes' do
      expect(change_set.changed?([:name, :age])).to eq true
    end

    it 'requires one change to match' do
      expect(change_set.changed?([:age, :phone])).to eq true
    end

    it 'requires all changes to match' do
      expect(change_set.changed?([:name, :age, :phone], :all)).to eq false
    end
  end

  describe '#get_change' do
    before(:each) { change_set.add_change(:name, 'foo') }

    it 'returns the change when found' do
      expect(change_set.get_change(:name).current).to eq 'foo'
    end

    it 'returns the Diffr::Change object' do
      expect(change_set.get_change(:name)).to be_instance_of(Pedanco::Diffr::Change)
    end

    it 'returns empty Diffr::Change if not found' do
      expect(change_set.get_change(:foo).current).to be_nil
      expect(change_set.get_change(:foo).previous).to be_nil
    end
  end

  describe '_changed? matchers' do
    before(:each) { change_set.add_change(:name, 'foo') }

    it 'returns true for changes that match' do
      expect(change_set.name_changed?).to be_truthy
    end

    it 'returns false for changes that do not exists' do
      expect(change_set.foo_changed?).to be_falsey
    end
  end

  describe '#to_a' do
    before(:each) { change_set.add_change(:name, 'foo') }

    it 'returns the change when found' do
      expect(change_set.to_a(:name)).to eq [nil, 'foo']
    end

    it 'returns nil if not found' do
      expect(change_set.to_a(:foo)).to eq []
    end
  end

  describe '#to_hash' do
    before(:each) { change_set.add_change(:name, 'foo') }

    it 'returns the change when found' do
      expect(change_set.to_hash).to include(name: [nil, 'foo'])
    end

  end

  describe '#parse_changes' do
    before(:each) { change_set.parse_changes('foo' => %w(baz bar), 'biff' => [10, 1]) }

    it 'extracts the changes' do
      expect(change_set.get_change(:foo).current).to eq 'bar'
      expect(change_set.get_change('biff').previous).to eq 10
    end
  end
end
