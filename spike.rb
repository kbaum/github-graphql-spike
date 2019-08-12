# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

md5_to_object_id = {}

client = Graphlient::Client.new('https://api.github.com/graphql',
                                headers: {
                                  'Authorization' => "bearer #{ENV['GITHUB_ACCESS_TOKEN']}"
                                })

response = client.query <<~GRAPHQL
  query {
     repository(name: "coverband", owner: "danmayer") {
      object(expression: "master:Gemfile") {
        ... on Blob {
          id
          oid
          text
        }
      }
    }
  }
GRAPHQL

hexdigest = Digest::MD5.hexdigest(response.data.repository.object.text)
# map hexdigest to git oid
# every hexdigest will need to be mapped to proper file in git allowing for
# mapping coverage data to an actual file
md5_to_object_id[hexdigest] = response.data.repository.object.oid

# lookup the file using hexdigest to git oid mapping
response = client.query <<~GRAPHQL
  query {
     repository(name: "coverband", owner: "danmayer") {
      object(oid: #{md5_to_object_id[hexdigest]}) {
        ... on Blob {
          id
          oid
          text
        }
      }
    }
  }
GRAPHQL

puts response.data.repository.object.oid
puts response.data.repository.object.text
