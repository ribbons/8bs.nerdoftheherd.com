# frozen_string_literal: true

# Copyright © 2019-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative '../../_plugins/BBC/bbc_file'

module BBCHelpers
  def get_file(name, tweaks: nil)
    fullpath = File.expand_path("../test_data/#{name}", __FILE__)
    content = File.open(fullpath, 'rb', &:read)

    BBC::BBCFile.new(0, '$', name, 0xFFFFFFFF, 0xFFFFFFFF, content, tweaks)
  end

  def file_from_string(content)
    BBC::BBCFile.new(0, '$', 'file', 0xFFFFFFFF, 0xFFFFFFFF, content)
  end
end
