module BBC
  class BBCFile
    def initialize(disc, side, dir, name, startsector, length)
      @disc = disc
      @side = side
      @dir = dir
      @name = name

      @buffer = []
      @sector = startsector
      @remaining = (length / DfsDisc::SECTOR_SIZE) + 1
      @lastlen = (length % DfsDisc::SECTOR_SIZE) + 1
    end

    attr_reader :side, :dir, :name, :disc

    def getbyte
      if @buffer.empty?
        return nil if @remaining == 0

        @buffer = @disc.read_sector(@side, @sector)
        @sector += 1
        @remaining -= 1

        # Remove the sector data after EOF from the buffer
        @buffer.slice!((@lastlen)..@buffer.length) if @remaining == 0
      end

      @buffer.shift
    end

    def readbyte
      byte = getbyte
      fail EOFError, 'end of file reached' if byte.nil?
      byte
    end

    def read
      data = ''

      until (byte = getbyte).nil?
        data << byte.chr
      end

      data
    end
  end
end
