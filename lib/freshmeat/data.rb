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

  class Project < Data; end
  class Comment < Data; end
  class Release < Data; end
  class Screenshot < Data; end
  class URL < Data; end
  class Tag < Data; end
end
