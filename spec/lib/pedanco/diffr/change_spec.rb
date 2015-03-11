require 'spec_helper'

describe Pedanco::Diffr::Change do
  context '#initialize' do
    it 'requires a name' do
      expect { Pedanco::Diffr::Change.new }.to raise_error
    end

    context 'default values' do
      subject { Pedanco::Diffr::Change.new(:foo) }

      it 'defaults current to nil' do
        expect(subject.current).to be_nil
      end

      it 'defaults previous to nil' do
        expect(subject.previous).to be_nil
      end
    end

    context 'passing values' do
      subject { Pedanco::Diffr::Change.new(:bar, 'baz', 'biff') }

      it 'sets the name' do
        expect(subject.name).to eq :bar
      end

      it 'sets the current' do
        expect(subject.current).to eq 'baz'
      end

      it 'sets the previous' do
        expect(subject.previous).to eq 'biff'
      end
    end
  end

  context '#to_a' do
    subject { Pedanco::Diffr::Change.new(:bar, 'baz', 'biff') }

    it 'orders the array correctly' do
      expect(subject.to_a).to eq %w(biff baz)
    end
  end
end
