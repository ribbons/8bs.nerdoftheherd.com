module EBS
  class Disc < Liquid::Drop
    def initialize(image, issue, menugroup)
      @imagepath = '/' + image
      @issue = issue
      @path = image[%r{/(8BS[0-9-]+)\.dsd$}, 1]
      @number = @path[/[0-9]-([0-9])/, 1] || '1'
      @menugroup = menugroup
    end

    attr_reader :imagepath, :issue, :path, :number, :menugroup
  end
end
