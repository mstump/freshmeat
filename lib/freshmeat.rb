require 'rubygems'
require 'httparty'
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
    @comments ||= get("/projects/#{project}/comments.json")
  end

  private

  def get(url)
    self.class.get(url, :query => {:auth_code => @auth_code}, :format => :json)
  end

end
