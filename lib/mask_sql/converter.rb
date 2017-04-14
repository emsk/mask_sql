require 'csv'
require 'yaml'

module MaskSql
  class Converter
    def initialize(options)
      @options = options
      config = YAML.load_file(options[:config])
      @mark = config['mark']
      @targets = config['targets']
      @options[:insert] = true if options[:insert].nil? && options[:replace].nil?
    end

    def mask
      File.open(@options[:out], 'w') do |out_file|
        File.open(@options[:in], 'r:utf-8') do |in_file|
          in_file.each_line do |line|
            write_line(line, out_file)
          end
        end
      end
    end

    private

    def write_line(line, output_file)
      @targets.each do |target|
        table = target['table']
        matched_line = match_line(line, table)
        next unless matched_line

        prefix = matched_line[1]
        all_values = matched_line[3]
        suffix = matched_line[4]

        columns = target['columns']
        indexes = target['indexes'].keys

        record_values = CSV.parse(all_values)[0].each_slice(columns).to_a
        record_values.map!.with_index(1) do |values, record_index|
          indexes.each do |mask_index|
            values[mask_index] = target['indexes'][mask_index].gsub(@mark, record_index.to_s)
            values[mask_index].insert(0, '(') if mask_index == 0
            values[mask_index].insert(-1, ')') if mask_index == columns - 1
          end
          values
        end

        output_file.puts "#{prefix}#{record_values.join(',')}#{suffix}"
        return
      end

      output_file.puts line
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

      nil
    end

    def sql_regexp(table, sql_kind)
      case sql_kind
      when :insert  then /\A(INSERT (INTO)?\s*`?#{table}`?.*VALUES\s*)([^;]+)(;?)\Z/
      when :replace then /\A(REPLACE (INTO)?\s*`?#{table}`?.*VALUES\s*)([^;]+)(;?)\Z/
      end
    end
  end
end
