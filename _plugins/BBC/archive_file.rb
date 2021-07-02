# frozen_string_literal: true

# Copyright © 2017-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module BBC
  require_relative 'dfs_disc'

  class ArchiveFile
    def initialize(files)
      @files = files.to_h do |file|
        [DfsDisc.canonicalise_path(file.path), file]
      end
    end

    def files
      @files.values
    end

    def file(path)
      path = DfsDisc.canonicalise_path(path)
      throw "#{path} not found in #{@path}" unless @files.key?(path)
      @files[path]
    end

    def <<(item)
      item.files.each do |file|
        @files[DfsDisc.canonicalise_path(file.path)] = file
      end
    end
  end
end
