require 'thor'

module GitJira
  class CLI < Thor
    include Thor::Actions

    desc 'config [OPTIONS]', 'Your config options'
    option :set, aliases: ['s'], desc: 'Set a config value KEY=VALUE'
    option :get, aliases: ['g'], desc: 'Get a config value'
    def config
      config = GitJira.config

      if options[:set]
        key, value = options[:set].split('=')
        config.set key, value
      elsif options[:get]
        say config.send(options[:get])
      else
        data = config.to_h
        data.each do |k, v|
          say "#{k}: #{v}"
        end
      end

    rescue GitJira::Config::UnknownKey => e
      say e, :red
    end

    desc 'open [ID]', 'Open the given ticket in jira.'
    def open(issue_id = nil)
      if issue_id
        %x{open #{GitJira.url_for_issue(issue_id)}}
      else
        %x{open #{GitJira.url}}
      end
    end

    desc 'info ID', 'Show the ticket summary for the given id.'
    def info(issue_id)
      issue = get_issue(issue_id, :all)

      say "#{issue.key}: ", :yellow
      say issue.summary, [:bold, :white]
      say "Components: ", :magenta
      say issue.component_names.join(', ')
      say issue.url, [:bold, :black]

      say "\nCreator: ", :blue
      say issue.creator['displayName']

      say "Assigned: ", :blue
      if issue.assignee
        say issue.assignee['displayName']
      else
        say 'Nobody'
      end

      say "Reviewer: ", :blue
      if issue.code_reviewer
        say issue.code_reviewer['displayName']
      else
        say 'None'
      end

      say "\nStatus: ", :cyan
      say issue.status['name']

      say "\n#{issue.description}\n\n"
    end

    desc 'copy ID [OPTIONS]', 'Copy the ticket url'
    option :markdown, aliases: ['m'], type: :boolean, desc: 'Copy as markdown (for PR)'
    def copy(id)
      url = GitJira.url_for_issue(id)

      if options[:markdown]
        url = "[#{ticket_id}](#{url})"
      end

      pbcopy url
    end

  private

    def get_issue(id, fields = :all, fail_if_not_found = true)
      issue = GitJira::IssueService.new.get(id, fields)

      unless issue.ok?
        issue.error_messages.each do |msg|
          say msg, :red
        end

        exit 1
      end if fail_if_not_found

      issue
    end

    # Tmux help, see: http://superuser.com/questions/231130/unable-to-use-pbcopy-while-in-tmux-session
    def pbcopy(string)
      IO.popen('pbcopy', 'w'){ |f| f << string }
      string
    end
  end
end
