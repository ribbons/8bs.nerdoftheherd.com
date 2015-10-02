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

    def content
      data = ''
      sector = @startsector
      remaining = (@length / DfsDisc::SECTOR_SIZE) + 1
      lastlen = (@length % DfsDisc::SECTOR_SIZE)

      loop do
        buffer = @disc.read_sector(@side, sector)
        sector += 1
        remaining -= 1

        if remaining == 0
          # Only include the sector data up to EOF
          data << buffer[0..lastlen]
          return data
        end

        data << buffer
      end
    end
  end
end
