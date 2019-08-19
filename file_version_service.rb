# frozen_string_literal: true

class FileVersionService
  def lookup_by_md5; end

  def client
    @client ||= Graphlient::Client.new('https://api.github.com/graphql',
                                       headers: {
                                         'Authorization' => "bearer #{ENV['GITHUB_ACCESS_TOKEN']}"
                                       })
  end

  def history(path)
    response = client.query <<~GRAPHQL
      {
        repository(owner: "danmayer", name: "coverband") {
          defaultBranchRef {
            target {
              ... on Commit {
                history(first: 100, path: "#{path}") {
                  nodes {
                    oid
                    id
                    committedDate
                  }
                }
              }
            }
          }
        }
      }
    GRAPHQL
  end

  def version_detail(path:, oid:)
    response = client.query <<~GRAPHQL
          {
            repository(name: "coverband", owner: "danmayer") {
              object(expression: "#{oid}:#{path}") {
                ... on Blob {
                  id
                  oid
                  text
                }
              }
            }
      }
    GRAPHQL
  end
end
