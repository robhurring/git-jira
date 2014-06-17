require 'uri'
require 'netrc'

module Jira
  class << self
    def url
      "https://#{domain}.atlassian.net"
    end

    def config
      @_config ||= Config.load!
    end

    def domain
      ENV['JIRA_DOMAIN']
    end

    def url_for_issue(id)
      %{#{url}/browse/#{normalize_id id}}
    end

    def normalize_id(id)
      unless id.to_s.start_with?('FY-')
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

require_relative 'jira/config'
require_relative 'jira/template'
require_relative 'jira/model'
require_relative 'jira/service'
require_relative 'jira/models/issue'
require_relative 'jira/services/issue'