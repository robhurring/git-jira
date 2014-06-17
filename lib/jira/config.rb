require 'fileutils'
require 'yaml'

module Jira
  class Config
    UnknownKey = Class.new(RuntimeError)

    DEFAULTS = {
      github_user: %x{whoami}.strip,
      repo_search_paths: '.',
      templates_path: File.expand_path('../../../templates', __FILE__),
      jira_domain: 'jira',
      max_branch_length: 50
    }

    class << self
      def load!
        if File.exist?(config_file)
          data = YAML.load_file(config_file)
          new(data)
        else
          new(DEFAULTS)
        end
      end

      def config_file
        File.join(config_dir, 'config.yml')
      end

      def config_dir
        File.expand_path('~/.git-jira')
      end
    end

    attr_accessor :jira_domain
    attr_accessor :github_user
    attr_accessor :repo_search_paths
    attr_accessor :templates_path
    attr_accessor :max_branch_length

    def initialize(data = {})
      # add in any defaults we don't have
      data = DEFAULTS.merge(data)

      data.each do |key, value|
        set(key, value)
      end
    end

    def get(key)
      to_h[key.to_sym]
    end

    def set(key, value)
      raise UnknownKey, 'Unknown config value' unless respond_to?(:"#{key}=")

      if value.nil?
        value = DEFAULTS[key.to_sym]
      end

      if value.is_a?(::String) && value.include?(',')
        value = value.split(',')
      end

      self.send(:"#{key}=", value)
      save!
    end

    def to_h
      {
        jira_domain: jira_domain,
        github_user: github_user,
        repo_search_paths: repo_search_paths,
        templates_path: templates_path,
        max_branch_length: max_branch_length
      }
    end

  private

    def save!
      unless Dir.exist?(self.class.config_dir)
        FileUtils.mkdir_p(self.class.config_dir)
      end

      File.open(self.class.config_file, 'w+') do |f|
        f << YAML.dump(to_h)
      end
    end
  end
end