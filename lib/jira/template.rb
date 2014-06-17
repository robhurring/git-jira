module Jira
  class Template
    class << self
      def lookup(name)
        Array(Jira.config.templates_path).each do |path|
          template_path = File.join(path, name.to_s)

          if File.exists?(template_path)
            return load(template_path)
          end
        end

        nil
      end

      def load(path)
        new File.read(path)
      end
    end

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def render(interpolations = {})
      data % interpolations
    end
  end
end
