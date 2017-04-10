RSpec.describe MaskSql::CLI do
  let(:help) do
    <<~EOS
      Commands:
        #{command} help [COMMAND]                                            # Describe available commands or one specific command
        #{command} mask -i, --in=INPUT FILE PATH -o, --out=OUTPUT FILE PATH  # Mask sensitive values in a SQL file
        #{command} version, -v, --version                                    # Print the version

    EOS
  end

  shared_examples_for 'a `mask` command with full options' do
    context 'when the config file exists' do
      let(:config) { YAML.load_file("#{File.dirname(__FILE__)}/../sqls/.mask.yml") }
      let(:out_file) { StringIO.new }
      let!(:in_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/insert.sql")) }
      let!(:masked_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/masked_insert.sql")) }

      before do
        expect(File).to receive(:expand_path).with('config.yml').and_return(config_file_path)
        expect(YAML).to receive(:load_file).with(config_file_path).and_return(config)
        expect(File).to receive(:open).with('out.sql', 'w').and_yield(out_file)
        expect(File).to receive(:open).with('in.sql', 'r:utf-8').and_yield(in_sql)

        described_class.start(thor_args)
      end

      subject { out_file.string }
      it { is_expected.to eq masked_sql }
    end

    context 'when the config file does not exist' do
      before do
        expect(File).to receive(:expand_path).with('config.yml').and_return(config_file_path)
      end

      it { is_expected.to raise_error(Errno::ENOENT, "No such file or directory @ rb_sysopen - #{config_file_path}") }
    end
  end

  shared_examples_for 'a `mask` command with required options' do
    context 'when a config file exists in the current directory' do
      let(:config) { YAML.load_file("#{File.dirname(__FILE__)}/../sqls/.mask.yml") }
      let(:out_file) { StringIO.new }
      let!(:in_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/insert.sql")) }
      let!(:masked_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/masked_insert.sql")) }

      before do
        expect(File).to receive(:expand_path).with('.mask.yml').and_return(config_file_path)
        expect(File).to receive(:exist?).with(config_file_path).and_return(true)
        expect(YAML).to receive(:load_file).with(config_file_path).and_return(config)
        expect(File).to receive(:open).with('out.sql', 'w').and_yield(out_file)
        expect(File).to receive(:open).with('in.sql', 'r:utf-8').and_yield(in_sql)

        described_class.start(thor_args)
      end

      subject { out_file.string }
      it { is_expected.to eq masked_sql }
    end

    context 'when a config file does not exist in the current directory' do
      before do
        expect(File).to receive(:expand_path).with('.mask.yml').and_return(config_file_path)
        expect(File).to receive(:exist?).with(config_file_path).and_return(false)
      end

      it { is_expected.to raise_error(TypeError, 'no implicit conversion of nil into String') }
    end
  end

  shared_examples_for 'a `help` command' do
    before do
      expect(File).to receive(:basename).with($PROGRAM_NAME).and_return(command).at_least(:once)
    end

    it { is_expected.to output(help).to_stdout }
  end

  describe '.start' do
    let(:command) { 'mask_sql' }

    subject { -> { described_class.start(thor_args) } }

    context 'given `mask -i in.sql -o out.sql -c config.yml`' do
      let(:thor_args) { %w(mask -i in.sql -o out.sql -c config.yml) }
      let(:config_file_path) { '/path/to/config.yml' }
      it_behaves_like 'a `mask` command with full options'
    end

    context 'given `mask --in in.sql --out out.sql --config config.yml`' do
      let(:thor_args) { %w(mask --in in.sql --out out.sql --config config.yml) }
      let(:config_file_path) { '/path/to/config.yml' }
      it_behaves_like 'a `mask` command with full options'
    end

    context 'given `mask -i in.sql -o out.sql`' do
      let(:thor_args) { %w(mask -i in.sql -o out.sql) }
      let(:config_file_path) { '/path/to/.mask.yml' }
      it_behaves_like 'a `mask` command with required options'
    end

    context 'given `mask --in in.sql --out out.sql`' do
      let(:thor_args) { %w(mask --in in.sql --out out.sql) }
      let(:config_file_path) { '/path/to/.mask.yml' }
      it_behaves_like 'a `mask` command with required options'
    end

    context 'given `mask`' do
      let(:thor_args) { %w(mask) }
      it { is_expected.to output("No value provided for required options '--in', '--out'\n").to_stderr }
    end

    context 'given `mask -i in.sql`' do
      let(:thor_args) { %w(mask -i in.sql) }
      it { is_expected.to output("No value provided for required options '--out'\n").to_stderr }
    end

    context 'given `mask -o out.sql`' do
      let(:thor_args) { %w(mask -o out.sql) }
      it { is_expected.to output("No value provided for required options '--in'\n").to_stderr }
    end

    context 'given `mask -i in.sql -c config.yml`' do
      let(:thor_args) { %w(mask -i in.sql -c config.yml) }
      it { is_expected.to output("No value provided for required options '--out'\n").to_stderr }
    end

    context 'given `mask -o out.sql -c config.yml`' do
      let(:thor_args) { %w(mask -o out.sql -c config.yml) }
      it { is_expected.to output("No value provided for required options '--in'\n").to_stderr }
    end

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

    context 'given `help`' do
      let(:thor_args) { %w(help) }
      it_behaves_like 'a `help` command'
    end

    context 'given `--help`' do
      let(:thor_args) { %w(--help) }
      it_behaves_like 'a `help` command'
    end

    context 'given `-h`' do
      let(:thor_args) { %w(-h) }
      it_behaves_like 'a `help` command'
    end

    context 'given `help mask`' do
      let(:thor_args) { %w(help mask) }
      let(:help) do
        <<~EOS
          Usage:
            #{command} mask -i, --in=INPUT FILE PATH -o, --out=OUTPUT FILE PATH

          Options:
            -i, --in=INPUT FILE PATH         
            -o, --out=OUTPUT FILE PATH       
            -c, [--config=CONFIG FILE PATH]  

          Mask sensitive values in a SQL file
        EOS
      end
      it_behaves_like 'a `help` command'
    end

    context 'given `help version`' do
      let(:thor_args) { %w(help version) }
      let(:help) do
        <<~EOS
          Usage:
            #{command} version, -v, --version

          Print the version
        EOS
      end
      it_behaves_like 'a `help` command'
    end

    context 'given `help help`' do
      let(:thor_args) { %w(help help) }
      let(:help) do
        <<~EOS
          Usage:
            #{command} help [COMMAND]

          Describe available commands or one specific command
        EOS
      end
      it_behaves_like 'a `help` command'
    end
  end
end
