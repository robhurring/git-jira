module Jira
  class IssueService < Service
    # TODO: allow config to have field aliases?
    DEFAULT_FIELDS = [
      "summary",
      "description",
      "reporter",
      "priority",
      "issuetype",
      "components",
      "status",
      "creator",
      "assignee",
      "customfield_10203",  # primary developer?
      "customfield_10202",  # code reviewer
      "customfield_10300"   # sponsor
    ]

    # TODO: Add these to config yaml?
    class << self
      def simple_fields
        'summary,description'
      end

      def all_fields
        DEFAULT_FIELDS.join(',')
      end
    end

    def get(id, fields = nil, expand = '')
      _fields = ''

      case fields
      when :simple
        _fields = self.class.simple_fields
      when :all
        _fields = self.class.all_fields
      else
        _fields = fields
      end

      id = Jira.normalize_id(id)

      response = self.class.get "/rest/api/2/issue/#{id}", query: {
        fields: _fields,
        expand: expand
      }

      Jira::Issue.new(response)
    end
  end
end