require 'httparty'

module Jira
  class Service
    include HTTParty

    base_uri Jira.url
    basic_auth *Jira.credentials
    format :json
  end
end
