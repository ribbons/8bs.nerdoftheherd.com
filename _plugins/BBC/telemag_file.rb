# frozen_string_literal: true

# Copyright © 2017-2022 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module BBC
  require_relative 'archive_file'
  require_relative 'basic_data_file'

  class TelemagFile < ArchiveFile
    extend ReadBasicData

    def self.parse(file)
      return nil if file.empty?

      files = []

      until file.empty?
        length = read_value(file)
        return nil unless length.is_a?(Float)

        length += MODE7_ROWS * MODE7_COLS
        return nil if file.length < length

        files << BBCFile.new(0, '$', (files.length + 65).chr, 0x0, 0x0,
                             file.shift(length), { parser: 'Mode7File' })
      end

      TelemagFile.new(files)
    end
  end
end
