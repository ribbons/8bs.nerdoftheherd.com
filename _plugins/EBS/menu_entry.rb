module EBS
  class MenuEntry < Liquid::Drop
    def initialize(disc)
      @disc = disc
    end

    attr_accessor :title, :type, :id
    attr_reader :path

    def path=(path)
      @path = @disc.canonicalise_path(path)
    end

    def linkpath
      if @type == :menu
        return '#menu' + @id
      else
        return 'content/' + Jekyll::Utils.slugify(@path) + '/'
      end
    end

    def content
      @disc.file(@path).reader.read
    end
  end
end
