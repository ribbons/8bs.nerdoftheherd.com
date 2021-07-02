# frozen_string_literal: true

# Copyright © 2017-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module BBC
  require_relative 'archive_file'

  class Arcver30File < ArchiveFile
    def self.parse(file)
      return nil if file.empty?

      # Begins with three zero ints
      3.times do
        return nil if BasicDataFile.read_value(file) != 0
      end

      # File version
      return nil if BasicDataFile.read_value(file) != '3.0'

      file_count = BasicDataFile.read_value(file)

      # Total size of files, archive creator and date
      return nil unless BasicDataFile.read_value(file).is_a?(Integer)
      return nil unless BasicDataFile.read_value(file).is_a?(String)
      return nil unless BasicDataFile.read_value(file).is_a?(String)

      # Lines of notes
      BasicDataFile.read_value(file).times do
        return nil unless BasicDataFile.read_value(file).is_a?(String)
      end

      files = []

      file_data = Array.new(file_count) do
        fileinfo = {
          name: BasicDataFile.read_value(file),
          load_addr: BasicDataFile.read_value(file) & 0xFFFFFFFF,
          exec_addr: BasicDataFile.read_value(file) & 0xFFFFFFFF,
          length: BasicDataFile.read_value(file),
        }

        return nil if BasicDataFile.read_value(file) != 0

        fileinfo
      end

      file_data.each do |fileinfo|
        # Each file has a number written before it for some reason
        unless BasicDataFile.read_value(file).is_a?(Integer)
          raise 'Invalid archive, expected int'
        end

        splitname = fileinfo[:name].split('.', 2)
        dir = splitname.count == 1 ? '$' : splitname.shift
        justname = splitname.shift

        files << BBCFile.new(0, dir, justname, fileinfo[:load_addr],
                             fileinfo[:exec_addr],
                             file.shift(fileinfo[:length]))
      end

      Arcver30File.new(files)
    end
  end
end
