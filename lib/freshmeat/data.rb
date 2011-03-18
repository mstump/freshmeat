class Freshmeat
  class Data
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def method_missing(method)
      data[method.to_s]
    end

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
