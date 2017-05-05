RSpec.describe MaskSQL::Initializer do
  describe '#copy_template' do
    let(:from) { File.expand_path("../../../lib/mask_sql/initializer/#{described_class::TEMPLATE_CONFIG_FILE}", __FILE__) }
    let(:to) { File.expand_path(described_class::TEMPLATE_CONFIG_FILE) }

    before do
      expect(FileTest).to receive(:exist?).with(to).and_return(config_file_exist)
    end

    subject { described_class.copy_template }

    context 'when destination config file exists' do
      let(:config_file_exist) { true }

      before do
        expect(FileUtils).not_to receive(:copy).with(from, to)
      end

      it { is_expected.to match(/\A\e\[33mexist .*#{Regexp.escape(described_class::TEMPLATE_CONFIG_FILE)}\e\[0m\z/) }
    end

    context 'when destination config file does not exist' do
      let(:config_file_exist) { false }

      before do
        expect(FileUtils).to receive(:copy).with(from, to)
      end

      it { is_expected.to match(/\A\e\[32mcreate .*#{Regexp.escape(described_class::TEMPLATE_CONFIG_FILE)}\e\[0m\z/) }
    end
  end
end
