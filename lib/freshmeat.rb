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
require 'httparty'
require 'time'
require File.dirname(__FILE__) + '/freshmeat/data'

class Freshmeat
  include HTTParty
  base_uri "freshmeat.net"

  attr_reader :auth_code

  def initialize(auth_code)
    @auth_code = auth_code
  end

  def project(project)
    @project ||= Project.new(get("/projects/#{project}.json")["project"])
  end

  def comments(project)
    @comments ||= get("/projects/#{project}/comments.json").map {|x| Comment.new(x["comment"])}
  end

  def releases(project)
    @releases ||= get("/projects/#{project}/releases.json").map {|x| Release.new(x["release"])}
  end

  def screenshots(project)
    @screenshots ||= get("/projects/#{project}/screenshots.json").map {|x| Screenshot.new(x["screenshot"])}
  end

  def urls(project)
    @urls ||= get("/projects/#{project}/urls.json").map {|x| URL.new(x["url"])}
  end

  def tag(tag)
    r = get("/tags/#{tag}.json")
    @tags ||= Tag.new(r["tag"], r["projects"].map {|x| Project.new(x)})
  end

  def tags()
    @tags ||= get("/tags/all.json").map {|x| Tag.new(x["tag"])}
  end

  def search(query, page=1, args={})
    @results ||= get("/search.json", args.merge({:q => query, :page => page}))["projects"].map {|x| Project.new(x["project"])}
  end

  private

    def get(url, args={})
      self.class.get(url, :query => args.merge({:auth_code => @auth_code}), :format => :json)
    end

end
