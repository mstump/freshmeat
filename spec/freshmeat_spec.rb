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

describe "fetch"

  FakeWeb.register_uri(:get, "http://freshmeat.net/projects/samba.json?auth_code=AAA", :body => File.read("spec/fixtures/samba.json"))
  FakeWeb.register_uri(:get, "http://freshmeat.net/projects/samba/comments.json?auth_code=AAA", :body => File.read("spec/fixtures/comments.json"))

  it "should fetch a project" do
    f = Freshmeat.new("AAA")
    print f.project("samba").methods
    f.project("samba").name.should == "Samba"
  end

  it "should fetch comments" do
    f = Freshmeat.new("AAA")
    f.comments("samba").length.should == 4
  end

end

__END__
