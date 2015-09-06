module BBC
  class BBCFile
    def initialize(disc, dir, name, startsector, length)
      @disc = disc
      @dir = dir
      @name = name

      @buffer = []
      @sector = startsector
      @remaining = (length / DfsDisc::SECTOR_SIZE) + 1
      @lastlen = (length % DfsDisc::SECTOR_SIZE) + 1
    end

    attr_reader :dir, :name

    def getbyte
      if @buffer.empty?
        return nil if @remaining == 0

        @buffer = @disc.read_sector(0, @sector)
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
  end
end
