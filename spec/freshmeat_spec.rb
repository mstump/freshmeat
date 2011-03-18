require 'spec_helper'

describe Freshmeat do

  describe "parameters" do
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
      f.project("samba").name.should == "Samba"
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
    end

    it "a particular tag" do
      f = Freshmeat.new("AAA")
      f.tags("960gs").length.should == 100
      f.tags("960gs")[0].user_id.should == 33614
    end

    it "search" do
      f = Freshmeat.new("AAA")
      f.search("foo").length.should == 10
      f.search("foo")[0].user_id.should == 33614
    end
  end
end

__END__
