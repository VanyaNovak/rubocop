# frozen_string_literal: true

RSpec.describe RuboCop::FeatureLoader do
  describe '.load' do
    subject(:load) do
      described_class.load(config_directory_path: config_directory_path, feature: feature)
    end

    let(:config_directory_path) do
      'path-to-config'
    end

    let(:feature) do
      'feature'
    end

    context 'with normally lodable feature' do
      before do
        allow(Kernel).to receive(:require)
      end

      it 'loads it normally' do
        expect(Kernel).to receive(:require).with('feature')
        load
      end
    end

    context 'with dot-prefixed lodable feature' do
      before do
        allow(Kernel).to receive(:require)
      end

      let(:feature) do
        './path/to/feature'
      end

      it 'loads it as relative path' do
        expect(Kernel).to receive(:require).with('path-to-config/./path/to/feature')
        load
      end
    end

    context 'with namespaced feature' do
      before do
        allow(Kernel).to receive(:require).with('feature-foo').and_call_original
        allow(Kernel).to receive(:require).with('feature/foo')
      end

      let(:feature) do
        'feature-foo'
      end

      it 'loads it as namespaced feature' do
        expect(Kernel).to receive(:require).with('feature/foo')
        load
      end
    end

    context 'with dot-prefixed namespaced feature' do
      before do
        allow(Kernel).to receive(:require).with('path-to-config/./feature-foo').and_call_original
        allow(Kernel).to receive(:require).with('path-to-config/./feature/foo')
      end

      let(:feature) do
        './feature-foo'
      end

      it 'loads it as namespaced feature' do
        expect(Kernel).to receive(:require).with('path-to-config/./feature/foo')
        load
      end
    end

    context 'with unexpected LoadError from require' do
      before do
        allow(Kernel).to receive(:require).and_raise(LoadError)
      end

      it 'raises LoadError' do
        expect { load }.to raise_error(LoadError)
      end
    end

    context 'with unloadable namespaced feature' do
      let(:feature) do
        'feature-foo'
      end

      # In normal Ruby, the message starts with "cannot load such file",
      # but in JRuby it seems to start with "no such file to load".
      it 'raises LoadError with preferred message' do
        expect { load }.to raise_error(LoadError, /feature-foo/)
      end
    end
  end
end
