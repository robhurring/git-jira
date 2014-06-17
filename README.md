# git-jira

This is a small git command to help with a Jira workflow. It will assist in creating branches based off ticket ID's as well as starting pull-requests. A few other useful things it can do are open the current branch's ticket and copy its URL.

## Caveats

Since we're using HTTParty and basic-auth you must have a username/password for your jira account. **Google authentication will not work.** To reset/create a password for your Jira account visit https://YOURDOMAIN.atlassian.net/login/forgot and reset your password.

## Installation

Clone this repo locally:

    git clone https://github.com/robhurring/git-jira.git

Install dependencies:

    bundle install

Install the gem:

    rake install

Configure your Jira authentication (currently only .netrc/basic auth):

    echo "machine DOMAIN.atlassian.net login user.name password s3cr1t" >> ~/.netrc
    chmod 600 ~/.netrc

## Configuration

`git jira config`

Theres a few things you can configure using the format `git jira config -s KEY=VALUE`

*Running this command will create a file at `~/.git-jira/config.yml` that you can modify as well.*

##### jira_domain

This is your subdomain on the jira site

##### github_user

This is used to prefix associated repos in the pull-requests. This can be your username or organization name.

##### repo_search_paths

When generating a pull-request walk all directories in `repo_search_paths` and see if the git repository is using the same branch name. If the branches match, it will be pulled into the pull-request as an 'Associated Repo'. Separate multiple paths with a ","

Example: `git jira config -s repo_search_paths=~/Sites/apps,~/Sites/gems`

##### templates_path

If you want to override any templates, place them in this folder. There is only the `pull_request` template currently.

Example: `git jira config -s templates_path=~/.my-templates`

##### max_branch_length

When creating a branch, use upto <thismany> chars from the summary.

## Commands

##### Branching

`git jira branch <TICKET ID> [DESCRIPTION]`

Pass in a given ticket id to start a new branch in the format "TICKET_FIRST_X_CHARS_OF_TICKET_SUMMARY"

If you pass in a description as the second argument it will use that as the description, otherwise it will fetch the ticket through the API and use the summary line.

##### Ticket Info

*Must be on a jira branch*

`git jira info`

If you are on a jira branch (one starting with FY-####) this will grab the ticket through the API and spit out some basic details about it; things like summary, description, asignee, reporter, reviewer, status, etc.

##### Open Ticket in Browser

*Must be on a jira branch*

`git jira open`

This will open the current branch's ticket in your browser

##### Pull-Requests

*Must be on a jira branch*

`git jira pull-request`
`git jira pull-request --create` *Uses the `hub` command to open the pull-request`

This will lookup a bunch of details about your branch and produce a pull-request template with the following things:

* The formatted title "TICKET#: Summary of ticket"
* A link to the ticket in the description
* Any associated apps/gems (see config section for more)
* The code reviewer

You can create your own pull-request template by updating the config setting `templates_path` (see config section)

## Templates

Templates will be searched for in `git jira config -g templates_path`

##### Pull-Requests

*Name: pull-request*
*Template: *

    /cc %{reviewer}

    %{ticket_link}

    ### Associated

    %{associated_repos}

    ### Summary

    ### Testing

The variables are:

* `reviewer`: The ticket's code reviewer's username (no github user mapping)
* `ticket_link`: A link to the ticket
* `associated_repos`: Any repo in `repo_search_paths` that is using the same branch. (See config section)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/git-jira/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
