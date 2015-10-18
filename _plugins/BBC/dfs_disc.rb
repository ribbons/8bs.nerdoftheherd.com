module BBC
  class DfsDisc
    TRACKS        = 40
    TRACK_SECTORS = 10
    SECTOR_SIZE   = 256
    TRACK_SIZE    = TRACK_SECTORS * SECTOR_SIZE

    FILEREC_SIZE  = 8

    def initialize(path)
      @path = path
      @file = File.new(@path, 'rb')

      @files = {}

      read_catalogue(0)
      read_catalogue(2)
    end

    private def read_catalogue(side)
      cat = []

      # Catalogue is in the first two sectors (0 & 1)
      2.times do |sector|
        cat += read_sector(side, sector).each_byte.to_a
      end

      # Sector 1, byte 5: Offset to the last valid file entry in the cat
      # Dividing by FILEREC_SIZE gives us the number of files on the disc
      numfiles = cat[SECTOR_SIZE + 5] / FILEREC_SIZE

      # Build a list of files on this disc
      numfiles.times do |filenum|
        offset = FILEREC_SIZE * (filenum + 1)
        name = ''

        # Sector 1:  Bytes 1-7 of the file record are the name
        cat[offset..offset + 6].each do |b|
          name += (b & 0x7F).chr
        end

        # Name is padded with spaces
        name.strip!

        # Bits 1-7 of Byte 8 is the directory
        dir = (cat[offset + 7] & 0x7F).chr

        # Sector 2: Bytes 5 & 6 and a couple of bits of 7 are the length
        length = ((cat[SECTOR_SIZE + offset + 6] & 0x30) << 12) | (cat[SECTOR_SIZE + offset + 5] << 8) | cat[SECTOR_SIZE + offset + 4]
        # Byte 8 and a couple of bits of 7 are the sector where the file starts
        startsector = ((cat[SECTOR_SIZE + offset + 6] & 0x03) << 8) | cat[SECTOR_SIZE + offset + 7]

        file = BBCFile.new(self, side, dir, name, startsector, length)
        @files[':' + file.side.to_s + '.' + file.dir.upcase + '.' + file.name.upcase] = file
      end
    end

    def file(path)
      @files[canonicalise_path(path)]
    end

    def read_sector(side, sector)
      track = sector / TRACK_SECTORS
      tracksector = sector % TRACK_SECTORS

      @file.seek(((track * 2 + (side / 2)) * TRACK_SECTORS + tracksector) * SECTOR_SIZE)
      @file.sysread(SECTOR_SIZE)
    end

    def canonicalise_path(path)
      split = path.sub(/^\.+/, '').upcase.split('.', 3)

      drive = split[0][0] == ':' ? split.shift : ':0'
      dir = split.size == 2 ? split.shift : '$'
      file = split.shift

      drive + '.' + dir + '.' + file
    end
  end
end
