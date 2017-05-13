require 'thor'
require 'mask_sql/converter'
require 'mask_sql/initializer'

module MaskSQL
  class CLI < Thor
    default_command :mask

    desc 'mask', 'Mask sensitive values in a SQL file'
    option :in, type: :string, aliases: '-i', required: true, banner: 'INPUT FILE PATH'
    option :out, type: :string, aliases: '-o', required: true, banner: 'OUTPUT FILE PATH'
    option :config, type: :string, aliases: '-c', banner: 'CONFIG FILE PATH'
    option :insert, type: :boolean, banner: 'MASK `INSERT` SQL'
    option :replace, type: :boolean, banner: 'MASK `REPLACE` SQL'
    option :copy, type: :boolean, banner: 'MASK `COPY` SQL'

    def mask
      return unless validate_options

      converter_options = options.dup

      if options[:config]
        converter_options[:config] = File.expand_path(options[:config])
      else
        default_config = File.expand_path('.mask.yml')
        converter_options[:config] = default_config if File.exist?(default_config)
      end

      converter = Converter.new(converter_options)
      converter.mask
      puts "\e[32mDone.\e[0m"
    end

    desc 'init', 'Generate a config file'

    def init
      puts Initializer.copy_template
    end

    desc 'version, -v, --version', 'Print the version'
    map %w[-v --version] => :version

    def version
      puts "mask_sql #{MaskSQL::VERSION}"
    end

    private

    def validate_options
      in_file = File.expand_path(options[:in])
      out_file = File.expand_path(options[:out])

      if in_file == out_file
        warn "\e[31mOutput file is the same as input file.\e[0m"
        return false
      end

      true
    end
  end
end
