require 'yaml'
require 'nkf'

module MaskSQL
  class Converter
    def initialize(options)
      @options = options

      config = YAML.load_file(options[:config])
      @mark = config['mark']
      @targets = config['targets']

      if options[:insert].nil? && options[:replace].nil? && options[:copy].nil?
        @options[:insert] = true
        @options[:replace] = true
        @options[:copy] = true
      end

      @matched_copy = {}
    end

    def mask(encoding = nil)
      encoding ||= NKF.guess(File.read(@options[:in])).name

      File.open(@options[:out], "w:#{encoding}") do |out_file|
        File.open(@options[:in], "r:#{encoding}") do |in_file|
          in_file.each_line do |line|
            @matched_copy.empty? ? write_line(line, out_file) : write_copy_line(line, out_file)
          end
        end
      end
    rescue Encoding::UndefinedConversionError => e
      raise Encoding::UndefinedConversionError, e.message if encoding == Encoding::UTF_8.name
      mask(Encoding::UTF_8.name)
    end

    private

    def write_line(line, output_file)
      @targets.each do |target|
        table = target['table']
        matched_line = match_line(line, table)
        next unless matched_line

        if matched_line.names.include?('copy_sql')
          output_file.puts line
          @matched_copy[:sql] = matched_line[:copy_sql]
          @matched_copy[:indexes] = target['indexes']
          @matched_copy[:record_index] = 1
          return
        end

        all_values = parse_all_values(matched_line[:all_values])

        columns = target['columns']
        indexes = target['indexes']

        record_values = get_record_values(all_values, columns)
        masked_values = mask_values(record_values, columns, indexes)

        output_file.puts "#{matched_line[:prefix]}#{masked_values.join(',')}#{matched_line[:suffix]}"
        return
      end

      output_file.puts line
    end

    def write_copy_line(line, output_file)
      if /^\\.$/ =~ line
        output_file.puts line
        @matched_copy.clear
        return
      end

      record_values = line.split("\t")
      @matched_copy[:indexes].each do |mask_index, mask_value|
        record_values[mask_index] = mask_value.sub(/^'/, '')
          .sub(/'$/, '')
          .gsub(@mark, @matched_copy[:record_index].to_s)
      end

      output_file.puts record_values.join("\t")
      @matched_copy[:record_index] += 1
    end

    def match_line(line, table)
      if @options[:insert]
        matched_line = sql_regexp(table, :insert).match(line)
        return matched_line if matched_line
      end

      if @options[:replace]
        matched_line = sql_regexp(table, :replace).match(line)
        return matched_line if matched_line
      end

      if @options[:copy]
        matched_line = sql_regexp(table, :copy).match(line)
        return matched_line if matched_line
      end

      nil
    end

    def sql_regexp(table, sql_kind)
      case sql_kind
      when :insert
        /^(?<prefix>INSERT (INTO)?\s*`?#{table}`?.*VALUES\s*)(?<all_values>[^;]+)(?<suffix>;?)$/i
      when :replace
        /^(?<prefix>REPLACE (INTO)?\s*`?#{table}`?.*VALUES\s*)(?<all_values>[^;]+)(?<suffix>;?)$/i
      when :copy
        /^(?<copy_sql>COPY\s*`?#{table}`?.*FROM stdin;)$/i
      end
    end

    def parse_all_values(matched_all_values)
      all_values = matched_all_values.chomp.split(',')
      processing_index = 0

      all_values.map!.with_index do |value, index|
        next if index != 0 && index <= processing_index

        if start_string?(value)
          processing_value = value.dup
          processing_index = index

          until end_string?(processing_value)
            processing_index += 1
            processing_value += all_values[processing_index]
          end

          value = processing_value
        end

        value
      end

      all_values.compact
    end

    def start_string?(value)
      value == "'" || value == "('" || (value.start_with?("'", "('") && !value.end_with?("'", "')"))
    end

    def end_string?(value)
      value != "'" && value != "('" && value.end_with?("'", "')")
    end

    def get_record_values(all_values, columns)
      all_values.each_slice(columns).to_a
    end

    def mask_values(record_values, columns, indexes)
      record_values.map!.with_index(1) do |values, record_index|
        indexes.each_key do |mask_index|
          before_value = values[mask_index]
          values[mask_index] = indexes[mask_index].gsub(@mark, record_index.to_s)
          values[mask_index].insert(0, "'") if before_value.start_with?("'", "('")
          values[mask_index].insert(-1, "'") if before_value.end_with?("'", "')")
          values[mask_index].insert(0, '(') if mask_index.zero?
          values[mask_index].insert(-1, ')') if mask_index == columns - 1
        end

        values
      end

      record_values
    end
  end
end
