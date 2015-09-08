module EBS
  class Disc < Liquid::Drop
    def initialize(image, menu)
      @imagepath = '/' + image
      @path = image[%r{/(8BS[0-9-]+)\.dsd$}, 1]
      @number = @path[/[0-9]-([0-9])/, 1] || '1'
      @menu = menu
    end

    attr_reader :imagepath, :path, :number, :menu
    attr_accessor :issue
  end
end
