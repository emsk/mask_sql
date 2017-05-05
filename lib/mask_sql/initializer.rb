module MaskSQL
  class Initializer
    TEMPLATE_CONFIG_FILE = '.mask.yml'.freeze

    def self.copy_template
      to = File.expand_path(TEMPLATE_CONFIG_FILE)
      return "\e[33mexist #{to}\e[0m" if FileTest.exist?(to)

      from = File.expand_path("../initializer/#{TEMPLATE_CONFIG_FILE}", __FILE__)
      FileUtils.copy(from, to)
      "\e[32mcreate #{to}\e[0m"
    end
  end
end
