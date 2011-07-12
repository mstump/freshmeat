=begin

  Copyright (c) 2011 Matthew Stump
  freshmeat_spec.rb

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

require 'rspec'
require 'net/http'
require 'spec_helper'

describe Freshmeat do

  def test_project_partial(p)
    p.permalink.is_a?(String).should == true
    p.fid.is_a?(Integer).should == true
    p.name.is_a?(String).should == true
    p.oneliner.is_a?(String).should == true
    p.description.is_a?(String).should == true
    p.license_list.is_a?(Array).should == true
    p.license_list.map { |t| t.is_a?(String).should == true }
  end

  def test_project(p)
    test_project_partial(p)
    p.popularity.is_a?(Numeric).should == true
    p.vitality.is_a?(Numeric).should == true
    p.created_at.is_a?(Time).should == true

    p.user.is_a?(Freshmeat::User).should == true

    p.project_filters_count.is_a?(Integer).should == true
    p.subscriptions_count.is_a?(Integer).should == true
    p.vote_score.is_a?(Integer).should == true

    p.programming_language_list.is_a?(Array).should == true
    p.operating_system_list.is_a?(Array).should == true
    p.tag_list.is_a?(Array).should == true

    p.programming_language_list.map { |t| t.is_a?(String).should == true }
    p.operating_system_list.map { |t| t.is_a?(String).should == true }
    p.tag_list.map { |t| t.is_a?(String).should == true }

    p.approved_urls.is_a?(Array).should == true
    p.approved_screenshots.is_a?(Array).should == true
    p.recent_releases.is_a?(Array).should == true

    p.approved_urls.map { |t| t.is_a?(Freshmeat::URL).should == true }
    p.approved_screenshots.map { |t| t.is_a?(Freshmeat::Screenshot).should == true }
    p.recent_releases.map { |t| t.is_a?(Freshmeat::Release).should == true }
  end

  describe "authcode" do
    it "should require an auth code" do
      lambda { Freshmeat.new }.should raise_error(ArgumentError, "wrong number of arguments (0 for 1)")
    end

    it "passing auth_code via new should set auth_code" do
      Freshmeat.new("AAA").auth_code.should == "AAA"
    end
  end

  describe "attributes of a single project: " do

    FakeWeb.register_uri(:get, "http://freshmeat.net/projects/samba.json?auth_code=AAA", :body => File.read("spec/fixtures/samba.json"))
    FakeWeb.register_uri(:get, "http://freshmeat.net/projects/samba/comments.json?auth_code=AAA", :body => File.read("spec/fixtures/comments.json"))
    FakeWeb.register_uri(:get, "http://freshmeat.net/projects/samba/releases.json?auth_code=AAA", :body => File.read("spec/fixtures/releases.json"))
    FakeWeb.register_uri(:get, "http://freshmeat.net/projects/samba/urls.json?auth_code=AAA", :body => File.read("spec/fixtures/urls.json"))
    FakeWeb.register_uri(:get, "http://freshmeat.net/projects/gimp/screenshots.json?auth_code=AAA", :body => File.read("spec/fixtures/screenshots.json"))

    it "overview" do
      f = Freshmeat.new("AAA")
      r = f.project("samba")
      r.name.should == "Samba"
      test_project(r)
    end

    it "comments" do
      f = Freshmeat.new("AAA")
      f.comments("samba").length.should == 4
      f.comments("samba")[0].user_id.should == 33614
    end

    it "releases" do
      f = Freshmeat.new("AAA")
      r = f.releases("samba")
      r.map { |t| t.fid.is_a?(Integer).should == true }
      r.map { |t| t.changelog.is_a?(String).should == true }
      r.map { |t| (!! t.hidden_from_frontpage == t.hidden_from_frontpage).should == true }
      r.map { |t| t.version.is_a?(String).should == true }
      r.map { |t| t.tag_list.is_a?(Array).should == true }
      r.map { |t| t.approved_at.is_a?(Time).should == true }
      r.map { |t| t.created_at.is_a?(Time).should == true }
      r.length.should == 100
    end

    it "screenshots" do
      f = Freshmeat.new("AAA")
      r = f.screenshots("gimp")
      r.map { |t| t.fid.is_a?(Integer).should == true }
      r.map { |t| t.created_at.is_a?(Time).should == true }
      r.map { |t| t.absolute_url.is_a?(String).should == true }
      r.map { |t| (t.title == nil || t.title.is_a?(String)).should == true }
      r.length.should == 1
    end

    it "urls" do
      f = Freshmeat.new("AAA")
      r = f.urls("samba")
      r.length.should == 11
      r.map { |t| t.fid.is_a?(Integer).should == true }
      r.map { |t| t.redirector.is_a?(String).should == true }
      r.map { |t| t.permalink.is_a?(String).should == true }
      r.map { |t| t.label.is_a?(String).should == true }
      r.map { |t| t.host.is_a?(String).should == true }
    end
  end

  describe "Fetching many projects and tags:" do
    FakeWeb.register_uri(:get, "http://freshmeat.net/search.json?q=foo&page=1&auth_code=AAA", :body => File.read("spec/fixtures/search.json"))
    FakeWeb.register_uri(:get, "http://freshmeat.net/tags/all.json?auth_code=AAA", :body => File.read("spec/fixtures/tags.json"))
    FakeWeb.register_uri(:get, "http://freshmeat.net/tags/960gs.json?auth_code=AAA", :body => File.read("spec/fixtures/tags_960gs.json"))

    it "all tags" do
      f = Freshmeat.new("AAA")
      r = f.tags()
      r.length.should == 100
      r.map { |t| t.fid.is_a?(Integer).should == true }
      r.map { |t| t.taggings_count.is_a?(Integer).should == true }
      r.map { |t| t.name.is_a?(String).should == true }
      r.map { |t| t.permalink.is_a?(String).should == true }
      r.map { |t| t.projects.is_a?(Array).should == true }
    end

    it "a particular tag" do
      f = Freshmeat.new("AAA")
      t = f.tag("960gs")
      t.fid.is_a?(Integer).should == true
      t.taggings_count.is_a?(Integer).should == true
      t.name.is_a?(String).should == true
      t.permalink.is_a?(String).should == true
      t.projects.is_a?(Array).should == true
      t.projects.length.should == 2

      t.projects.map { |p| p.is_a?(Freshmeat::Project).should == true }
      t.projects.map { |p| test_project(p) }
    end

    it "search" do
      f = Freshmeat.new("AAA")
      r = f.search("foo")
      r.length.should == 10
      r.map { |t| t.is_a?(Freshmeat::Project).should == true }
      r.map { |t| test_project(t) }
    end
  end

  describe "fetching recently released projects from the undocumented frontpage API: " do
    FakeWeb.register_uri(:get, "http://freshmeat.net/index.json?auth_code=AAA", :body => File.read("spec/fixtures/recently_released.json"))

    it "return a list of projects" do
      f = Freshmeat.new("AAA")
      r = f.recently_released_projects()
      r.map { |p| p.is_a?(Freshmeat::PartialProject).should == true }
      r.map { |p| test_project_partial(p) }
    end

    it "return a list of projects who have one release each" do
      f = Freshmeat.new("AAA")
      f.recently_released_projects().map { |p| p.recent_releases.length.should == 1 }
      f.recently_released_projects().each do |p|
        p.recent_releases.each do |z|
          z.map { |t| t.fid.is_a?(Integer).should == true }
          z.map { |t| t.changelog.is_a?(String).should == true }
          z.map { |t| (!! t.hidden_from_frontpage == t.hidden_from_frontpage).should == true }
          z.map { |t| t.version.is_a?(String).should == true }
          z.map { |t| t.tag_list.is_a?(Array).should == true }
          z.map { |t| t.approved_at.is_a?(Time).should == true }
          z.map { |t| t.created_at.is_a?(Time).should == true }
        end
      end
      f.recently_released_projects().map { |p| test_project_partial(p) }
    end
  end

  it "going over the API limit should throw an exception" do
    FakeWeb.register_uri(:get, "http://freshmeat.net/search.json?q=amforth&page=1&auth_code=AAA",
                         :body => File.read("spec/fixtures/overlimit.json"),
                         :status => ["503", "Service Temporarily Unavailable"])
    f = Freshmeat.new("AAA")
    lambda {
      f.search("amforth")
    }.should raise_error(FreshmeatAPICreditsExceeded)
  end

  it "an unexpected HTTP error should result in an HTTPException and we shouldn't attempt to parse" do
    FakeWeb.register_uri(:get, "http://freshmeat.net/search.json?q=amforth&page=1&auth_code=AAA",
                         :status => ["500", "Internal Server Error"])
    f = Freshmeat.new("AAA")
    lambda {
      f.search("amforth")
    }.should raise_error(Net::HTTPFatalError, "500 \"Internal Server Error\"")
  end

  it "Bad authentication attempt should result in an exception" do
    FakeWeb.register_uri(:get, "http://freshmeat.net/search.json?q=amforth&page=1&auth_code=AAA",
                         :status => ["401", "Authorization Required"])
    f = Freshmeat.new("AAA")
    lambda {
      f.search("amforth")
    }.should raise_error(Net::HTTPServerException, "401 \"Authorization Required\"")
  end


end
