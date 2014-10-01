require 'uri'
require 'netrc'

module GitJira
  class << self
    def url
      "https://#{domain}.atlassian.net"
    end

    def config
      @_config ||= Config.load!
    end

    def domain
      config.jira_domain
    end

    def url_for_issue(id)
      %{#{url}/browse/#{normalize_id id}}
    end

    def normalize_id(id)
      unless id.to_s =~ /[A-Z]+\-\d+/
        id = "FY-#{id}"
      end

      id
    end

    def credentials
      hostname = URI.parse(url).host
      Netrc.read[hostname]
    end
  end
end

require_relative 'git-jira/config'
require_relative 'git-jira/template'
require_relative 'git-jira/model'
require_relative 'git-jira/service'
require_relative 'git-jira/models/issue'
require_relative 'git-jira/services/issue'
