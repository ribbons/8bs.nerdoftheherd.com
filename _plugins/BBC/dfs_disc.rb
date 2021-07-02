# frozen_string_literal: true

# Copyright © 2015-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module BBC
  class DfsDisc
    TRACKS        = 80
    TRACK_SECTORS = 10
    SECTOR_SIZE   = 256
    TRACK_SIZE    = TRACK_SECTORS * SECTOR_SIZE
    TOTAL_SECTORS = TRACKS * TRACK_SECTORS

    FILEREC_SIZE  = 8
    MAX_FILES     = 31

    OPTION_OFF    = 0x00
    OPTION_LOAD   = 0x10
    OPTION_RUN    = 0x20
    OPTION_EXEC   = 0x30

    def initialize(path, tweaks)
      @path = path
      @file = File.new(@path, 'rb')
      @dsd = @path =~ /\.dsd$/

      @files = {}

      filetweaks = tweaks&.fetch(:files, nil)
      read_catalogue(0, filetweaks&.fetch(0, nil))
      read_catalogue(2, filetweaks&.fetch(2, nil)) if @dsd

      tweaks&.fetch(:merge, nil)&.each do |merge|
        into = file(merge.shift)

        merge.each do |from|
          into << @files.delete(self.class.canonicalise_path(from))
        end
      end
    end

    def files
      @files.values
    end

    def file(path)
      path = self.class.canonicalise_path(path)
      throw "#{path} not found in #{@path}" unless @files.key?(path)
      @files[path]
    end

    def self.canonicalise_path(path)
      split = path.sub(/^\.+/, '').upcase.split('.', 3)

      drive = split[0][0] == ':' ? split.shift : ':0'
      dir = split.size == 2 && split[0].size == 1 ? split.shift : '$'
      file = split.join('.')

      "#{drive}.#{dir}.#{file}"
    end

    def self.generate_disc(name, files)
      disc = build_catalogue(name, files)

      files.each do |file|
        padding = SECTOR_SIZE - file.length % SECTOR_SIZE
        disc << file.content
        disc << ' ' * padding
      end

      disc
    end

    private

    def read_catalogue(side, tweaks)
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

        # Sector 2: Bytes 1 & 2 are the load address
        loadaddr = (cat[SECTOR_SIZE + offset + 1] << 8) |
                   cat[SECTOR_SIZE + offset]

        # Bytes 5 & 6 and a couple of bits of 7 are the length
        length = ((cat[SECTOR_SIZE + offset + 6] & 0x30) << 12) |
                 (cat[SECTOR_SIZE + offset + 5] << 8) |
                 cat[SECTOR_SIZE + offset + 4]

        # Byte 8 and a couple of bits of 7 are the sector where the file starts
        startsector = ((cat[SECTOR_SIZE + offset + 6] & 0x03) << 8) |
                      cat[SECTOR_SIZE + offset + 7]

        file = BBCFile.new(side, dir, name, loadaddr, nil,
                           file_content(side, startsector, length),
                           tweaks&.fetch("#{dir}.#{name}", nil))

        @files[":#{side}.#{dir.upcase}.#{name.upcase}"] = file
      end
    end

    def read_sector(side, sector)
      track = sector / TRACK_SECTORS
      track = track * 2 + (side / 2) if @dsd

      tracksector = sector % TRACK_SECTORS

      @file.seek((track * TRACK_SECTORS + tracksector) * SECTOR_SIZE)
      @file.sysread(SECTOR_SIZE)
    end

    def file_content(side, startsector, length)
      data = String.new
      sector = startsector
      remaining = length.fdiv(DfsDisc::SECTOR_SIZE).ceil
      lastlen = (length % DfsDisc::SECTOR_SIZE)
      lastlen = DfsDisc::SECTOR_SIZE if lastlen.zero?

      loop do
        buffer = read_sector(side, sector)
        sector += 1
        remaining -= 1

        if remaining.zero?
          # Only include the sector data up to EOF
          data << buffer[0..lastlen - 1]
          return data
        end

        data << buffer
      end
    end

    private_class_method def self.build_catalogue(name, files)
      name = name.ljust(12, 0.chr)

      cat = name[0...8] # First 8 bytes of disc title
      pad_entries = MAX_FILES - files.count

      files.each do |file|
        cat << file.name.ljust(7, ' ')[0...7]
        cat << file.dir
      end

      # Pad out to the end of the first catalogue sector
      cat << ' ' * (pad_entries * FILEREC_SIZE)

      cat << name[8...12] # Rest of the disc title
      cat << 0.chr        # Cycle number

      # Offset to last valid file entry in the catalogue
      cat << (files.count * FILEREC_SIZE).chr

      # Boot option & sectors in volume (bits 9 & 10)
      cat << (OPTION_EXEC | ((TOTAL_SECTORS & 0x300) >> 8)).chr

      # Sectors in volume (bits 1-8)
      cat << (TOTAL_SECTORS & 0xFF).chr

      offset = 2

      files.each do |file|
        sectors = (file.length / SECTOR_SIZE) + 1

        cat << (file.loadaddr & 0xFF).chr
        cat << ((file.loadaddr & 0xFF00) >> 8).chr
        cat << (file.execaddr & 0xFF).chr
        cat << ((file.execaddr & 0xFF00) >> 8).chr
        cat << (file.length & 0xFF).chr
        cat << ((file.length & 0xFF00) >> 8).chr

        # The top two bits of the exec addr, length, load addr & start sector
        cat << (((file.execaddr & 0x30000) >> 10) |
                ((file.length & 0x30000) >> 12) |
                ((file.loadaddr & 0x30000) >> 14) |
                ((offset & 0x300) >> 8)).chr

        cat << (offset & 0xFF).chr

        offset += sectors
      end

      # Pad out to the end of the second catalogue sector
      cat << ' ' * (pad_entries * FILEREC_SIZE)

      cat
    end
  end
end
