RSpec.describe MaskSql::CLI do
  describe '.start' do
    let(:command) { 'mask_sql' }

    subject { -> { described_class.start(thor_args) } }

    context 'given `version`' do
      let(:thor_args) { %w(version) }
      it { is_expected.to output("#{command} #{MaskSql::VERSION}\n").to_stdout }
    end

    context 'given `--version`' do
      let(:thor_args) { %w(--version) }
      it { is_expected.to output("#{command} #{MaskSql::VERSION}\n").to_stdout }
    end

    context 'given `-v`' do
      let(:thor_args) { %w(-v) }
      it { is_expected.to output("#{command} #{MaskSql::VERSION}\n").to_stdout }
    end
  end
end
