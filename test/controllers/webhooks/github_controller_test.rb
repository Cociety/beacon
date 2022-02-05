require "test_helper"

class Webhooks::GithubControllerTest < ActionDispatch::IntegrationTest
  test "responds to push events" do
    post webhooks_github_url, **{ params: github_params, headers: {'X-GitHub-Event': 'push'} }
    assert_response :ok
  end

  test "responds 404 to non push events" do
    post webhooks_github_url, **{ params: github_params, headers: {'X-GitHub-Event': 'ping'} }
    assert_response :not_found
  end

  test "responds 500 without a payload" do
    post webhooks_github_url, headers: {'X-GitHub-Event': 'push'}
    assert_response :ok
  end

  private

  def github_params
    payload = {
      "ref": "refs/heads/main",
      "before": "b21c585fa36bcbd90b09e4831a15fc06f7f1cbd4",
      "after": "e7571c7b3e0856e527c8b826a253d3604459722f",
      "repository": {
        "id": 326548432,
        "node_id": "MDEwOlJlcG9zaXRvcnkzMjY1NDg0MzI=",
        "name": "beacon",
        "full_name": "Cociety/beacon",
        "private": false,
        "owner": {
          "name": "Cociety",
          "email": nil,
          "login": "Cociety",
          "id": 76923865,
          "node_id": "MDEyOk9yZ2FuaXphdGlvbjc2OTIzODY1",
          "avatar_url": "https://avatars.githubusercontent.com/u/76923865?v=4",
          "gravatar_id": "",
          "url": "https://api.github.com/users/Cociety",
          "html_url": "https://github.com/Cociety",
          "followers_url": "https://api.github.com/users/Cociety/followers",
          "following_url": "https://api.github.com/users/Cociety/following{/other_user}",
          "gists_url": "https://api.github.com/users/Cociety/gists{/gist_id}",
          "starred_url": "https://api.github.com/users/Cociety/starred{/owner}{/repo}",
          "subscriptions_url": "https://api.github.com/users/Cociety/subscriptions",
          "organizations_url": "https://api.github.com/users/Cociety/orgs",
          "repos_url": "https://api.github.com/users/Cociety/repos",
          "events_url": "https://api.github.com/users/Cociety/events{/privacy}",
          "received_events_url": "https://api.github.com/users/Cociety/received_events",
          "type": "Organization",
          "site_admin": false
        },
        "html_url": "https://github.com/Cociety/beacon",
        "description": nil,
        "fork": false,
        "url": "https://github.com/Cociety/beacon",
        "forks_url": "https://api.github.com/repos/Cociety/beacon/forks",
        "keys_url": "https://api.github.com/repos/Cociety/beacon/keys{/key_id}",
        "collaborators_url": "https://api.github.com/repos/Cociety/beacon/collaborators{/collaborator}",
        "teams_url": "https://api.github.com/repos/Cociety/beacon/teams",
        "hooks_url": "https://api.github.com/repos/Cociety/beacon/hooks",
        "issue_events_url": "https://api.github.com/repos/Cociety/beacon/issues/events{/number}",
        "events_url": "https://api.github.com/repos/Cociety/beacon/events",
        "assignees_url": "https://api.github.com/repos/Cociety/beacon/assignees{/user}",
        "branches_url": "https://api.github.com/repos/Cociety/beacon/branches{/branch}",
        "tags_url": "https://api.github.com/repos/Cociety/beacon/tags",
        "blobs_url": "https://api.github.com/repos/Cociety/beacon/git/blobs{/sha}",
        "git_tags_url": "https://api.github.com/repos/Cociety/beacon/git/tags{/sha}",
        "git_refs_url": "https://api.github.com/repos/Cociety/beacon/git/refs{/sha}",
        "trees_url": "https://api.github.com/repos/Cociety/beacon/git/trees{/sha}",
        "statuses_url": "https://api.github.com/repos/Cociety/beacon/statuses/{sha}",
        "languages_url": "https://api.github.com/repos/Cociety/beacon/languages",
        "stargazers_url": "https://api.github.com/repos/Cociety/beacon/stargazers",
        "contributors_url": "https://api.github.com/repos/Cociety/beacon/contributors",
        "subscribers_url": "https://api.github.com/repos/Cociety/beacon/subscribers",
        "subscription_url": "https://api.github.com/repos/Cociety/beacon/subscription",
        "commits_url": "https://api.github.com/repos/Cociety/beacon/commits{/sha}",
        "git_commits_url": "https://api.github.com/repos/Cociety/beacon/git/commits{/sha}",
        "comments_url": "https://api.github.com/repos/Cociety/beacon/comments{/number}",
        "issue_comment_url": "https://api.github.com/repos/Cociety/beacon/issues/comments{/number}",
        "contents_url": "https://api.github.com/repos/Cociety/beacon/contents/{+path}",
        "compare_url": "https://api.github.com/repos/Cociety/beacon/compare/{base}...{head}",
        "merges_url": "https://api.github.com/repos/Cociety/beacon/merges",
        "archive_url": "https://api.github.com/repos/Cociety/beacon/{archive_format}{/ref}",
        "downloads_url": "https://api.github.com/repos/Cociety/beacon/downloads",
        "issues_url": "https://api.github.com/repos/Cociety/beacon/issues{/number}",
        "pulls_url": "https://api.github.com/repos/Cociety/beacon/pulls{/number}",
        "milestones_url": "https://api.github.com/repos/Cociety/beacon/milestones{/number}",
        "notifications_url": "https://api.github.com/repos/Cociety/beacon/notifications{?since,all,participating}",
        "labels_url": "https://api.github.com/repos/Cociety/beacon/labels{/name}",
        "releases_url": "https://api.github.com/repos/Cociety/beacon/releases{/id}",
        "deployments_url": "https://api.github.com/repos/Cociety/beacon/deployments",
        "created_at": 1609727372,
        "updated_at": "2021-10-01T12:27:37Z",
        "pushed_at": 1644031983,
        "git_url": "git://github.com/Cociety/beacon.git",
        "ssh_url": "git@github.com:Cociety/beacon.git",
        "clone_url": "https://github.com/Cociety/beacon.git",
        "svn_url": "https://github.com/Cociety/beacon",
        "homepage": nil,
        "size": 1099,
        "stargazers_count": 0,
        "watchers_count": 0,
        "language": "Ruby",
        "has_issues": true,
        "has_projects": true,
        "has_downloads": true,
        "has_wiki": true,
        "has_pages": false,
        "forks_count": 0,
        "mirror_url": nil,
        "archived": false,
        "disabled": false,
        "open_issues_count": 0,
        "license": nil,
        "allow_forking": true,
        "is_template": false,
        "topics": [

        ],
        "visibility": "public",
        "forks": 0,
        "open_issues": 0,
        "watchers": 0,
        "default_branch": "main",
        "stargazers": 0,
        "master_branch": "main",
        "organization": "Cociety"
      },
      "pusher": {
        "name": "justin-robinson",
        "email": "justinorobinson@icloud.com"
      },
      "organization": {
        "login": "Cociety",
        "id": 76923865,
        "node_id": "MDEyOk9yZ2FuaXphdGlvbjc2OTIzODY1",
        "url": "https://api.github.com/orgs/Cociety",
        "repos_url": "https://api.github.com/orgs/Cociety/repos",
        "events_url": "https://api.github.com/orgs/Cociety/events",
        "hooks_url": "https://api.github.com/orgs/Cociety/hooks",
        "issues_url": "https://api.github.com/orgs/Cociety/issues",
        "members_url": "https://api.github.com/orgs/Cociety/members{/member}",
        "public_members_url": "https://api.github.com/orgs/Cociety/public_members{/member}",
        "avatar_url": "https://avatars.githubusercontent.com/u/76923865?v=4",
        "description": ""
      },
      "sender": {
        "login": "justin-robinson",
        "id": 3090489,
        "node_id": "MDQ6VXNlcjMwOTA0ODk=",
        "avatar_url": "https://avatars.githubusercontent.com/u/3090489?v=4",
        "gravatar_id": "",
        "url": "https://api.github.com/users/justin-robinson",
        "html_url": "https://github.com/justin-robinson",
        "followers_url": "https://api.github.com/users/justin-robinson/followers",
        "following_url": "https://api.github.com/users/justin-robinson/following{/other_user}",
        "gists_url": "https://api.github.com/users/justin-robinson/gists{/gist_id}",
        "starred_url": "https://api.github.com/users/justin-robinson/starred{/owner}{/repo}",
        "subscriptions_url": "https://api.github.com/users/justin-robinson/subscriptions",
        "organizations_url": "https://api.github.com/users/justin-robinson/orgs",
        "repos_url": "https://api.github.com/users/justin-robinson/repos",
        "events_url": "https://api.github.com/users/justin-robinson/events{/privacy}",
        "received_events_url": "https://api.github.com/users/justin-robinson/received_events",
        "type": "User",
        "site_admin": false
      },
      "created": false,
      "deleted": false,
      "forced": false,
      "base_ref": nil,
      "compare": "https://github.com/Cociety/beacon/compare/b21c585fa36b...e7571c7b3e08",
      "commits": [
        {
          "id": "e7571c7b3e0856e527c8b826a253d3604459722f",
          "tree_id": "5c64bf3c42bbba0e32172b206d0da25af114ec4f",
          "distinct": true,
          "message": "testing github hooks",
          "timestamp": "2022-02-04T22:33:02-05:00",
          "url": "https://github.com/Cociety/beacon/commit/e7571c7b3e0856e527c8b826a253d3604459722f",
          "author": {
            "name": "Justin Robinson",
            "email": "justinorobinson@icloud.com",
            "username": "justin-robinson"
          },
          "committer": {
            "name": "Justin Robinson",
            "email": "justinorobinson@icloud.com",
            "username": "justin-robinson"
          },
          "added": [
            ".delete-me"
          ],
          "removed": [

          ],
          "modified": [

          ]
        }
      ],
      "head_commit": {
        "id": "e7571c7b3e0856e527c8b826a253d3604459722f",
        "tree_id": "5c64bf3c42bbba0e32172b206d0da25af114ec4f",
        "distinct": true,
        "message": "testing github hooks",
        "timestamp": "2022-02-04T22:33:02-05:00",
        "url": "https://github.com/Cociety/beacon/commit/e7571c7b3e0856e527c8b826a253d3604459722f",
        "author": {
          "name": "Justin Robinson",
          "email": "justinorobinson@icloud.com",
          "username": "justin-robinson"
        },
        "committer": {
          "name": "Justin Robinson",
          "email": "justinorobinson@icloud.com",
          "username": "justin-robinson"
        },
        "added": [
          ".delete-me"
        ],
        "removed": [

        ],
        "modified": [

        ]
      }
    }

    { payload: payload.to_json }
  end
end
