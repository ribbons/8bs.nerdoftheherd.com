module EBS
  class MenuEntry < Liquid::Drop
    def initialize(disc, linkpaths)
      @disc = disc
      @linkpaths = linkpaths
    end

    attr_accessor :title, :type, :id
    attr_reader :path

    def path=(path)
      @path = @disc.canonicalise_path(path)
      @linkpath = Jekyll::Utils.slugify(@path)

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
      @disc.file(@path).content
    end
  end
end
