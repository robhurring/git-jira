require_relative './cli'

module GitJira
  class GitCLI < CLI
    desc 'open', 'Opens the ticket for your current branch'
    def open
      super branch_ticket_id
    end

    desc 'info', 'Show the ticket summary for the current branch'
    def info
      super branch_ticket_id
    end

    desc 'copy [OPTIONS]', 'Copy the ticket url for the current branch'
    def copy
      super branch_ticket_id
    end

  # git-jira specific actions

    desc 'branch TICKET_ID [DESCRIPTION]', 'Start a branch for the given ticket.'
    long_desc 'If no description is given one will be generated from the ticket summary.'
    def branch(id, description = nil)
      id = GitJira.normalize_id(id)

      # build a description if none exists
      if description.nil?
        issue = get_issue(id, :summary)
        description = issue.fields['summary'].downcase.gsub(/\W/, '_').squeeze('_')
      end

      description = description[0..GitJira.config.max_branch_length].chomp('_')
      branch_name = "#{id}_#{description}"

      %x{git checkout -b #{branch_name}}
    end

    desc 'pull-request [OPTIONS]', 'Open a standard pull-request for this branch using GitJira details'
    long_desc %{
      Builds a pull-request based off this branch. It will try to do the following:\n
        - Generate a title with the ticket number and summary\n
        - Find any other repos that are using this same branch and add them\n
        - Lookup who the code reviewer is
    }
    option :create, aliases: 'c', type: :boolean, default: false, desc: 'Create pull-request using `hub` tool and open it (copied otherwise)'
    def pull_request
      ticket_id = branch_ticket_id
      template = Template.lookup(:pull_request)
      associated = find_associated_repos

      # magic, find the summary and code_reviewer fields only
      # TODO: don't be magical here
      issue = get_issue(ticket_id, 'summary,customfield_10202')
      reviewer = issue.code_reviewer['name'] rescue '???'

      title = "#{issue.key}: #{issue.summary}"
      body = template.render(
        ticket_link: %{[#{ticket_id}](#{issue.url})},
        associated_repos: associated.map{ |r| "#{GitJira.config.github_user}/#{r}" }.join("\n"),
        reviewer: reviewer
      )

      pull_request = %{#{title}\n\n#{body}}

      if options[:create]
        IO.popen('hub pull-request --browse -F -', 'w') do |f|
          f << pull_request
        end
        say "Pull request opening...", :green
      else
        pbcopy pull_request
        say "Pull request copied to clipboard!", :green
      end
    end

  private

    def branch_ticket_id(fail_if_not_found = true)
      id = extract_ticket_id(current_branch)

      unless id
        say "Couldn't figure out which ticket this branch is linked to", :red
        exit 1
      end if fail_if_not_found

      id
    end

    def current_branch
      %x{git rev-parse --abbrev-ref HEAD}
    end

    def extract_ticket_id(string)
      return $1 if string =~ /(FY-\d+)/
      nil
    end

    # search our `LINKED_REPO_PATHS` to see what other repos are using our
    # current branch (probably don't want this on 'dev' branch)
    def find_associated_repos
      linked = []
      my_branch = current_branch
      my_dir = Dir.getwd

      Array(GitJira.config.repo_search_paths).each do |path|
        path = File.expand_path(path)
        Dir["#{path}/*"].each do |dir|
          next if dir == my_dir

          Dir.chdir(dir) do
            # TODO: search branches, not just current one
            repo_branch = %x{git rev-parse --abbrev-ref HEAD}
            linked << File.basename(dir) if repo_branch == my_branch
          end
        end
      end

      linked
    end
  end
end
