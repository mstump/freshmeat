=begin

  Copyright (c) 2011 Matthew Stump
  data.rb

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

class Freshmeat
  class Data
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def method_missing(method)
      data[method.to_s]
    end

    # freshmeat object id
    def fid
      data["id"]
    end

    def inspect
      "#<#{self.class}:0x#{object_id}>"
    end

  end

  class Tag < Data

    def initialize(data, projects=Array.[])
      @data = data
      @data["projects"] = projects
    end

  end

  class Project < Data

    def initialize(data)
      @data = data
      @data["user"] = User.new(@data["user"])
      @data["approved_screenshots"] = @data["approved_screenshots"].map { |t| Screenshot.new(t) }
      @data["approved_urls"] = @data["approved_urls"].map { |t| URL.new(t) }
      @data["recent_releases"] = @data["recent_releases"].map { |t| Release.new(t) }
    end

  end

  class Comment < Data; end
  class Release < Data; end
  class Screenshot < Data; end
  class URL < Data; end
  class User < Data; end
end
