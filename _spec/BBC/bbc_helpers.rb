# frozen_string_literal: true

# Copyright © 2019-2022 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative '../../_plugins/BBC/bbc_file'

module BBCHelpers
  def get_file(name, loadaddr: 0xFFFFFFFF, execaddr: 0xFFFFFFFF, tweaks: nil)
    fullpath = File.expand_path("../test_data/#{name}", __FILE__)
    content = File.binread(fullpath)

    BBC::BBCFile.new(0, '$', name, loadaddr, execaddr, content, tweaks)
  end

  def file_from_string(content, loadaddr: 0xFFFFFFFF, execaddr: 0xFFFFFFFF)
    BBC::BBCFile.new(0, '$', 'file', loadaddr, execaddr, content)
  end
end
