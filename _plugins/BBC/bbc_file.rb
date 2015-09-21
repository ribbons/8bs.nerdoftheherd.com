module BBC
  class BBCFile
    def initialize(disc, side, dir, name, startsector, length)
      @disc = disc
      @side = side
      @dir = dir
      @name = name
      @startsector = startsector
      @length = length
    end

    attr_reader :side, :dir, :name, :disc

    def reader
      BBCFileReader.new(@disc, @side, @startsector, @length)
    end
  end
end
