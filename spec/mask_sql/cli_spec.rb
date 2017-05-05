RSpec.describe MaskSQL::CLI do
  let(:help) do
    <<-EOS
Commands:
  #{command} help [COMMAND]                                            # Describe available commands or one specific command
  #{command} init                                                      # Generate a config file
  #{command} mask -i, --in=INPUT FILE PATH -o, --out=OUTPUT FILE PATH  # Mask sensitive values in a SQL file
  #{command} version, -v, --version                                    # Print the version

    EOS
  end

  shared_examples_for 'a `mask` command with full options' do |options|
    context 'when the config file exists' do
      let(:config) { YAML.load_file("#{File.dirname(__FILE__)}/../sqls/.mask.yml") }
      let(:out_file) { StringIO.new }
      let(:sql_kind) do
        if options.nil? || (options[:insert].nil? && options[:replace].nil? && options[:copy].nil?)
          'all'
        elsif options[:insert] && !options[:replace] && !options[:copy]
          'insert'
        elsif !options[:insert] && options[:replace] && !options[:copy]
          'replace'
        elsif !options[:insert] && !options[:replace] && options[:copy]
          'copy'
        end
      end

      if options.nil? || options[:encoding].nil? || options[:encoding] == 'utf8'
        let!(:external_encoding) { Encoding::UTF_8.name }
        let!(:in_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/original.sql")) }
        let!(:masked_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/masked_#{sql_kind}.sql")) }
      elsif options[:encoding] == 'sjis'
        let!(:external_encoding) { Encoding::Shift_JIS.name }
        let!(:in_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/original_sjis.sql"), encoding: Encoding::Shift_JIS) }
        let!(:masked_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/masked_#{sql_kind}_sjis.sql"), encoding: Encoding::Shift_JIS) }
      elsif options[:encoding] == 'ascii'
        let!(:external_encoding) { Encoding::ASCII.name }
        let!(:in_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/original_ascii.sql"), encoding: Encoding::ASCII) }
        let!(:masked_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/masked_#{sql_kind}_ascii.sql"), encoding: Encoding::ASCII) }
      end

      before do
        out_file.set_encoding(external_encoding)
        expect(File).to receive(:expand_path).with('config.yml').and_return(config_file_path)
        expect(YAML).to receive(:load_file).with(config_file_path).and_return(config)
        expect(File).to receive(:read).with('in.sql').and_return(in_sql)
        expect(File).to receive(:open).with('out.sql', "w:#{external_encoding}").and_yield(out_file)
        expect(File).to receive(:open).with('in.sql', "r:#{external_encoding}").and_yield(in_sql)

        if !options.nil? && options[:encoding] == 'ascii'
          expect(File).to receive(:open).with('out.sql', "w:#{Encoding::UTF_8.name}").and_yield(out_file)
          expect(File).to receive(:open).with('in.sql', "r:#{Encoding::UTF_8.name}").and_yield(in_sql)
          allow(out_file).to receive(:puts).and_call_original

          @call_count = 0
          expect(out_file).to receive(:puts) do
            @call_count += 1
            raise Encoding::UndefinedConversionError if @call_count == 1
          end
        end

        described_class.start(thor_args)
      end

      subject { out_file.string }
      it { is_expected.to eq masked_sql }
    end

    context 'when the config file does not exist' do
      before do
        expect(File).to receive(:expand_path).with('config.yml').and_return(config_file_path)
      end

      it { is_expected.to raise_error(Errno::ENOENT, /No such file or directory( @ rb_sysopen)? - #{config_file_path}/) }
    end
  end

  shared_examples_for 'a `mask` command with full options and Encoding::UndefinedConversionError' do
    let(:config) { YAML.load_file("#{File.dirname(__FILE__)}/../sqls/.mask.yml") }
    let(:out_file) { StringIO.new }
    let!(:external_encoding) { Encoding::ASCII.name }
    let!(:in_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/original_ascii.sql"), encoding: Encoding::ASCII) }

    before do
      out_file.set_encoding(external_encoding)
      expect(File).to receive(:expand_path).with('config.yml').and_return(config_file_path)
      expect(YAML).to receive(:load_file).with(config_file_path).and_return(config)
      expect(File).to receive(:read).with('in.sql').and_return(in_sql)
      expect(File).to receive(:open).with('out.sql', "w:#{external_encoding}").and_yield(out_file)
      expect(File).to receive(:open).with('in.sql', "r:#{external_encoding}").and_yield(in_sql)
      expect(File).to receive(:open).with('out.sql', "w:#{Encoding::UTF_8.name}").and_yield(out_file)
      expect(File).to receive(:open).with('in.sql', "r:#{Encoding::UTF_8.name}").and_yield(in_sql)

      @call_count = 0
      expect(out_file).to receive(:puts).at_least(1) do
        @call_count += 1
        raise Encoding::UndefinedConversionError if @call_count == 1
        raise Encoding::UndefinedConversionError, 'ABC' if @call_count == 2
      end
    end

    subject { -> { described_class.start(thor_args) } }
    it { is_expected.to raise_error(Encoding::UndefinedConversionError, 'ABC') }
  end

  shared_examples_for 'a `mask` command with required options' do
    context 'when a config file exists in the current directory' do
      let(:config) { YAML.load_file("#{File.dirname(__FILE__)}/../sqls/.mask.yml") }
      let(:out_file) { StringIO.new }
      let!(:in_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/original.sql")) }
      let!(:masked_sql) { File.read(File.expand_path("#{File.dirname(__FILE__)}/../sqls/masked_all.sql")) }

      before do
        expect(File).to receive(:expand_path).with('.mask.yml').and_return(config_file_path)
        expect(File).to receive(:exist?).with(config_file_path).and_return(true)
        expect(YAML).to receive(:load_file).with(config_file_path).and_return(config)
        expect(File).to receive(:read).with('in.sql').and_return(in_sql)
        expect(File).to receive(:open).with('out.sql', 'w:UTF-8').and_yield(out_file)
        expect(File).to receive(:open).with('in.sql', 'r:UTF-8').and_yield(in_sql)

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

    context 'given `mask -i in.sql -o out.sql -c config.yml --insert --replace --copy`' do
      let(:thor_args) { %w[mask -i in.sql -o out.sql -c config.yml --insert --replace --copy] }
      let(:config_file_path) { '/path/to/config.yml' }

      context 'when the input file encoding is UTF-8' do
        it_behaves_like 'a `mask` command with full options'
      end

      context 'when the input file encoding is Shift_JIS' do
        it_behaves_like 'a `mask` command with full options', encoding: 'sjis'
      end

      context 'when the input file encoding is US-ASCII' do
        it_behaves_like 'a `mask` command with full options', encoding: 'ascii'
      end

      context 'when the input file encoding is US-ASCII and UTF-8' do
        it_behaves_like 'a `mask` command with full options and Encoding::UndefinedConversionError'
      end
    end

    context 'given `mask -i in.sql -o out.sql -c config.yml --insert`' do
      let(:thor_args) { %w[mask -i in.sql -o out.sql -c config.yml --insert] }
      let(:config_file_path) { '/path/to/config.yml' }
      it_behaves_like 'a `mask` command with full options', insert: true
    end

    context 'given `mask -i in.sql -o out.sql -c config.yml --replace`' do
      let(:thor_args) { %w[mask -i in.sql -o out.sql -c config.yml --replace] }
      let(:config_file_path) { '/path/to/config.yml' }
      it_behaves_like 'a `mask` command with full options', replace: true
    end

    context 'given `mask -i in.sql -o out.sql -c config.yml --copy`' do
      let(:thor_args) { %w[mask -i in.sql -o out.sql -c config.yml --copy] }
      let(:config_file_path) { '/path/to/config.yml' }
      it_behaves_like 'a `mask` command with full options', copy: true
    end

    context 'given `mask -i in.sql -o out.sql -c config.yml`' do
      let(:thor_args) { %w[mask -i in.sql -o out.sql -c config.yml] }
      let(:config_file_path) { '/path/to/config.yml' }
      it_behaves_like 'a `mask` command with full options'
    end

    context 'given `-i in.sql -o out.sql -c config.yml`' do
      let(:thor_args) { %w[-i in.sql -o out.sql -c config.yml] }
      let(:config_file_path) { '/path/to/config.yml' }
      it_behaves_like 'a `mask` command with full options'
    end

    context 'given `mask --in in.sql --out out.sql --config config.yml`' do
      let(:thor_args) { %w[mask --in in.sql --out out.sql --config config.yml] }
      let(:config_file_path) { '/path/to/config.yml' }
      it_behaves_like 'a `mask` command with full options'
    end

    context 'given `--in in.sql --out out.sql --config config.yml`' do
      let(:thor_args) { %w[--in in.sql --out out.sql --config config.yml] }
      let(:config_file_path) { '/path/to/config.yml' }
      it_behaves_like 'a `mask` command with full options'
    end

    context 'given `mask -i in.sql -o out.sql`' do
      let(:thor_args) { %w[mask -i in.sql -o out.sql] }
      let(:config_file_path) { '/path/to/.mask.yml' }
      it_behaves_like 'a `mask` command with required options'
    end

    context 'given `-i in.sql -o out.sql`' do
      let(:thor_args) { %w[-i in.sql -o out.sql] }
      let(:config_file_path) { '/path/to/.mask.yml' }
      it_behaves_like 'a `mask` command with required options'
    end

    context 'given `mask --in in.sql --out out.sql`' do
      let(:thor_args) { %w[mask --in in.sql --out out.sql] }
      let(:config_file_path) { '/path/to/.mask.yml' }
      it_behaves_like 'a `mask` command with required options'
    end

    context 'given `--in in.sql --out out.sql`' do
      let(:thor_args) { %w[--in in.sql --out out.sql] }
      let(:config_file_path) { '/path/to/.mask.yml' }
      it_behaves_like 'a `mask` command with required options'
    end

    context 'given `mask`' do
      let(:thor_args) { %w[mask] }
      it { is_expected.to output("No value provided for required options '--in', '--out'\n").to_stderr }
    end

    context 'given ``' do
      let(:thor_args) { %w[] }
      it { is_expected.to output("No value provided for required options '--in', '--out'\n").to_stderr }
    end

    context 'given `mask -i in.sql`' do
      let(:thor_args) { %w[mask -i in.sql] }
      it { is_expected.to output("No value provided for required options '--out'\n").to_stderr }
    end

    context 'given `-i in.sql`' do
      let(:thor_args) { %w[-i in.sql] }
      it { is_expected.to output("No value provided for required options '--out'\n").to_stderr }
    end

    context 'given `mask -o out.sql`' do
      let(:thor_args) { %w[mask -o out.sql] }
      it { is_expected.to output("No value provided for required options '--in'\n").to_stderr }
    end

    context 'given `-o out.sql`' do
      let(:thor_args) { %w[-o out.sql] }
      it { is_expected.to output("No value provided for required options '--in'\n").to_stderr }
    end

    context 'given `mask -i in.sql -c config.yml`' do
      let(:thor_args) { %w[mask -i in.sql -c config.yml] }
      it { is_expected.to output("No value provided for required options '--out'\n").to_stderr }
    end

    context 'given `-i in.sql -c config.yml`' do
      let(:thor_args) { %w[-i in.sql -c config.yml] }
      it { is_expected.to output("No value provided for required options '--out'\n").to_stderr }
    end

    context 'given `mask -o out.sql -c config.yml`' do
      let(:thor_args) { %w[mask -o out.sql -c config.yml] }
      it { is_expected.to output("No value provided for required options '--in'\n").to_stderr }
    end

    context 'given `-o out.sql -c config.yml`' do
      let(:thor_args) { %w[-o out.sql -c config.yml] }
      it { is_expected.to output("No value provided for required options '--in'\n").to_stderr }
    end

    context 'given `init`' do
      let(:thor_args) { %w[init] }

      before do
        expect(MaskSQL::Initializer).to receive(:copy_template).and_return('ABC')
      end

      it { is_expected.to output("ABC\n").to_stdout }
    end

    context 'given `version`' do
      let(:thor_args) { %w[version] }
      it { is_expected.to output("#{command} #{MaskSQL::VERSION}\n").to_stdout }
    end

    context 'given `--version`' do
      let(:thor_args) { %w[--version] }
      it { is_expected.to output("#{command} #{MaskSQL::VERSION}\n").to_stdout }
    end

    context 'given `-v`' do
      let(:thor_args) { %w[-v] }
      it { is_expected.to output("#{command} #{MaskSQL::VERSION}\n").to_stdout }
    end

    context 'given `help`' do
      let(:thor_args) { %w[help] }
      it_behaves_like 'a `help` command'
    end

    context 'given `--help`' do
      let(:thor_args) { %w[--help] }
      it_behaves_like 'a `help` command'
    end

    context 'given `-h`' do
      let(:thor_args) { %w[-h] }
      it_behaves_like 'a `help` command'
    end

    context 'given `h`' do
      let(:thor_args) { %w[h] }
      it_behaves_like 'a `help` command'
    end

    context 'given `he`' do
      let(:thor_args) { %w[he] }
      it_behaves_like 'a `help` command'
    end

    context 'given `hel`' do
      let(:thor_args) { %w[hel] }
      it_behaves_like 'a `help` command'
    end

    context 'given `help mask`' do
      let(:thor_args) { %w[help mask] }
      let(:help) do
        <<-EOS
Usage:
  #{command} mask -i, --in=INPUT FILE PATH -o, --out=OUTPUT FILE PATH

Options:
  -i, --in=INPUT FILE PATH                            
  -o, --out=OUTPUT FILE PATH                          
  -c, [--config=CONFIG FILE PATH]                     
      [--insert=MASK `INSERT` SQL], [--no-insert]     
      [--replace=MASK `REPLACE` SQL], [--no-replace]  
      [--copy=MASK `COPY` SQL], [--no-copy]           

Mask sensitive values in a SQL file
        EOS
      end
      it_behaves_like 'a `help` command'
    end

    context 'given `help init`' do
      let(:thor_args) { %w[help init] }
      let(:help) do
        <<-EOS
Usage:
  #{command} init

Generate a config file
        EOS
      end
      it_behaves_like 'a `help` command'
    end

    context 'given `help version`' do
      let(:thor_args) { %w[help version] }
      let(:help) do
        <<-EOS
Usage:
  #{command} version, -v, --version

Print the version
        EOS
      end
      it_behaves_like 'a `help` command'
    end

    context 'given `help help`' do
      let(:thor_args) { %w[help help] }
      let(:help) do
        <<-EOS
Usage:
  #{command} help [COMMAND]

Describe available commands or one specific command
        EOS
      end
      it_behaves_like 'a `help` command'
    end

    context 'given `abc`' do
      let(:thor_args) { %w[abc] }
      it { is_expected.to output(%(Could not find command "abc".\n)).to_stderr }
    end

    context 'given `helpp`' do
      let(:thor_args) { %w[helpp] }
      it { is_expected.to output(%(Could not find command "helpp".\n)).to_stderr }
    end
  end
end
