module EBS
  class MenuEntry < Liquid::Drop
    def initialize(disc, linkpaths)
      @disc = disc
      @linkpaths = linkpaths
    end

    attr_accessor :title, :type, :id
    attr_reader :paths

    def paths=(paths)
      @paths = []

      paths.each do |path|
        @paths << @disc.canonicalise_path(path)
      end

      @linkpath = Jekyll::Utils.slugify(@paths[0])

      # Make the path unique if it collides with an existing one
      if @linkpaths.key?(@linkpath)
        suffix = 1
        suffix += 1 while @linkpaths.key?(@linkpath + '-' + suffix.to_s)
        @linkpath << '-' + suffix.to_s
      end

      @linkpaths[@linkpath] = 1
    end

    def linkpath
      if @type == :menu
        return '#menu' + @id.to_s
      else
        return 'content/' + @linkpath + '/'
      end
    end

    def content
      content = []

      @paths.each do |path|
        content << @disc.file(path).content
      end

      content
    end
  end
end
