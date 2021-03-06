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
            if @matched_copy.empty?
              @counters = []
              write_line(line, out_file)
            else
              write_copy_line(line, out_file)
            end
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
        matched_line = match_line(line, target['table'])
        next unless matched_line

        if matched_line.names.include?('copy_sql')
          output_file.puts line
          init_matched_copy(target)
          return
        end

        all_values = parse_all_values(matched_line[:all_values])

        record_values = get_record_values(all_values, target['columns'])
        masked_values = mask_values(record_values, target)

        output_file.puts "#{matched_line[:prefix]}#{masked_values.join(',')}#{matched_line[:suffix]}"
        return
      end

      output_file.puts line
    end

    def init_matched_copy(target)
      @matched_copy[:dummy_values] = target['dummy_values']
      @matched_copy[:group_indexes] = target['group_indexes'] || []
      @matched_copy[:record_index] = 1
      @counters = []
    end

    def write_copy_line(line, output_file)
      if /^\\.$/ =~ line
        output_file.puts line
        @matched_copy.clear
        return
      end

      record_values = line.split("\t")
      count = get_current_count(record_values, @matched_copy[:record_index], @matched_copy[:group_indexes])

      @matched_copy[:dummy_values].each do |dummy_index, dummy_value|
        record_values[dummy_index] = dummy_value.sub(/^'/, '')
          .sub(/'$/, '')
          .gsub(@mark, count.to_s)
      end

      output_file.puts record_values.join("\t")
      @matched_copy[:record_index] += 1
    end

    def match_line(line, table)
      matched_line = match_insert(line, table)
      return matched_line if matched_line

      matched_line = match_replace(line, table)
      return matched_line if matched_line

      matched_line = match_copy(line, table)
      return matched_line if matched_line

      nil
    end

    def match_insert(line, table)
      return unless @options[:insert]
      /^(?<prefix>INSERT (INTO)?\s*`?#{table}`?.*VALUES\s*)(?<all_values>[^;]+)(?<suffix>;?)$/i.match(line)
    end

    def match_replace(line, table)
      return unless @options[:replace]
      /^(?<prefix>REPLACE (INTO)?\s*`?#{table}`?.*VALUES\s*)(?<all_values>[^;]+)(?<suffix>;?)$/i.match(line)
    end

    def match_copy(line, table)
      return unless @options[:copy]
      /^(?<copy_sql>COPY\s*`?#{table}`?.*FROM stdin;)$/i.match(line)
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

    def mask_values(record_values, target)
      columns = target['columns']
      dummy_values = target['dummy_values']
      group_indexes = target['group_indexes'] || []

      record_values.map!.with_index(1) do |values, record_index|
        count = get_current_count(values, record_index, group_indexes)

        dummy_values.each_key do |dummy_index|
          original_value = values[dummy_index]
          masked_value = dummy_values[dummy_index].gsub(@mark, count.to_s)
          values[dummy_index] = mask_value(masked_value, original_value, dummy_index, columns)
        end

        values
      end

      record_values
    end

    def get_current_count(values, record_index, group_indexes)
      return record_index if group_indexes.empty?

      group_values = group_indexes.map do |group_index|
        values[group_index]
      end
      increment_count(group_values)
    end

    def increment_count(group_values)
      counter = @counters.find do |c|
        c[:label] == group_values
      end

      if counter
        counter[:count] += 1
      else
        counter = { label: group_values, count: 1 }
        @counters.push(counter)
      end

      counter[:count]
    end

    def mask_value(masked_value, original_value, mask_index, columns)
      masked_value.insert(0, "'") if original_value.start_with?("'", "('")
      masked_value.insert(-1, "'") if original_value.end_with?("'", "')")
      masked_value.insert(0, '(') if mask_index.zero?
      masked_value.insert(-1, ')') if mask_index == columns - 1
      masked_value
    end
  end
end
