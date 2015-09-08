module EBS
  class Disc < Liquid::Drop
    def initialize(image, issue, menu)
      @imagepath = '/' + image
      @issue = issue
      @path = image[%r{/(8BS[0-9-]+)\.dsd$}, 1]
      @number = @path[/[0-9]-([0-9])/, 1] || '1'
      @menu = menu
    end

    attr_reader :imagepath, :issue, :path, :number, :menu
  end
end
