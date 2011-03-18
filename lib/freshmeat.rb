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

  def tags(tag=nil)
    if tag != nil
      @tags ||= get("/tags/#{tag}.json")["projects"].map {|x| Project.new(x["project"])}
    else
      @tags ||= get("/tags/all.json").map {|x| Tag.new(x["tag"])}
    end
  end

  def search(query, page=1, args={})
    @results ||= get("/search.json", args.merge({:q => query, :page => page}))["projects"].map {|x| Project.new(x["project"])}
  end

  private

    def get(url, args={})
      self.class.get(url, :query => args.merge({:auth_code => @auth_code}), :format => :json)
    end

end
