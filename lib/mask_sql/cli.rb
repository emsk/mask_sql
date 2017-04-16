require 'thor'
require 'mask_sql/converter'

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

    desc 'version, -v, --version', 'Print the version'
    map %w(-v --version) => :version

    def version
      puts "mask_sql #{MaskSQL::VERSION}"
    end
  end
end
