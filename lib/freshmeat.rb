=begin

  Copyright (c) 2011 Matthew Stump
  freshmeat.rb

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

=end

require 'rubygems'
require 'net/http'
require 'httparty'
require 'time'
require File.dirname(__FILE__) + '/freshmeat/data'

class FreshmeatAPICreditsExceeded < RuntimeError; end

# Simple wrapper around the Freshmeat.net data and frontpage API.  For
# detailed information about the attributes of each datatype please
# see the Freshmeat.net API documentation.
class Freshmeat
  include HTTParty
  base_uri "freshmeat.net"

  attr_reader :auth_code

  # Auth code is the API authorization code provided by freshmeat
  def initialize(auth_code)
    @auth_code = auth_code
  end

  # Get project by the permalink
  def project(project)
    @project = Project.new(get("/projects/#{project}.json")["project"])
  end

  # Get the most recently released projects, this list corresponds
  # with the Freshmeat front page and RSS feed.  The data returned by
  # the frontpage API is inconsistant with that returned by the data
  # API.  To draw attention to this fact we use the class
  # PartialProject to signify that you only have access to a subset of
  # the normal attributes.  This subset consists of:
  #  * permalink
  #  * fid (Freshmeat object id)
  #  * name
  #  * oneliner
  #  * description
  #  * license_list
  #  * recent_releases which is limited to the most recent release
  def recently_released_projects()
    get("/index.json").map { |x|
      p = x["release"]["project"]
      x.delete("project")
      p["recent_releases"] = [x["release"]]
      PartialProject.new(p)
    }
  end

  # Fetch the list of comments for the project specified by the project permalink
  def comments(project)
    @comments ||= get("/projects/#{project}/comments.json").map {|x| Comment.new(x["comment"])}
  end

  # Fetch the list of releases for the project specified by the project permalink
  def releases(project)
    @releases ||= get("/projects/#{project}/releases.json").map {|x| Release.new(x["release"])}
  end

  # Fetch the list of screenshots for the project specified by the project permalink
  def screenshots(project)
    @screenshots ||= get("/projects/#{project}/screenshots.json").map {|x| Screenshot.new(x["screenshot"])}
  end

  # Fetch the list of URLs for the project specified by the project permalink
  def urls(project)
    @urls ||= get("/projects/#{project}/urls.json").map {|x| URL.new(x["url"])}
  end

  # Fetch the list of projects matching tag
  def tag(tag)
    r = get("/tags/#{tag}.json")
    @tags ||= Tag.new(r["tag"], r["projects"].map {|x| Project.new(x)})
  end

  # Fetch the entire list of tags
  def tags()
    @tags ||= get("/tags/all.json").map {|x| Tag.new(x["tag"])}
  end

  # Search for project by string with optional pagination
  def search(query, page=1, args={})
    @results ||= get("/search.json", args.merge({:q => query, :page => page}))["projects"].map {|x| Project.new(x["project"])}
  end

  private

    def get(url, args={})
      response = self.class.get(url, :query => args.merge({:auth_code => @auth_code}), :format => :json)
      case response.code
        when 200
          return response
        when 503
          if response["status"]
            raise FreshmeatAPICreditsExceeded.new(response["status"])
          else
            response.error!
          end
        else
          response.error!
      end
    end

end
