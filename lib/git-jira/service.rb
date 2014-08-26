require 'httparty'

module GitJira
  class Service
    include HTTParty

    base_uri GitJira.url
    basic_auth *GitJira.credentials
    format :json
  end
end
