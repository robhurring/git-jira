module GitJira
  class Issue < Model
    def initialize(*)
      super
      build_field_accessors if fields.is_a?(::Hash)
    end

    def url
      GitJira.url_for_issue(key)
    end

    def component_names
      components.map{ |c| c['name'] }
    end

    def primary_developer
      customfield_10203
    rescue
      nil
    end

    def code_reviewer
      customfield_10202
    rescue
      nil
    end

    def sponsor
      customfield_10300
    rescue
      nil
    end

  private

    def build_field_accessors
      fields.keys.each do |acc|
        self.class.send(:define_method, acc){ fields[acc] }
      end
    end
  end
end