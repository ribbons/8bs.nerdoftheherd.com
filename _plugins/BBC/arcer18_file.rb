# frozen_string_literal: true

# Copyright © 2017-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module BBC
  require_relative 'archive_file'

  class Arcer18File < ArchiveFile
    def self.parse(file)
      return nil if file.empty?

      files = []

      until file.empty?
        filename = BasicDataFile.read_value(file)
        return nil unless filename.is_a?(String)

        length = BasicDataFile.read_value(file)
        return nil unless length.is_a?(Integer)

        load_addr = BasicDataFile.read_value(file)
        return nil unless load_addr.is_a?(Integer)

        exec_addr = BasicDataFile.read_value(file)
        return nil unless exec_addr.is_a?(Integer)

        splitname = filename.split('.', 2)
        dir = splitname.count == 1 ? '$' : splitname.shift
        justname = splitname.shift

        files << BBCFile.new(0, dir, justname, load_addr & 0xFFFFFFFF,
                             exec_addr & 0xFFFFFFFF, file.shift(length))
      end

      Arcer18File.new(files)
    end
  end
end
