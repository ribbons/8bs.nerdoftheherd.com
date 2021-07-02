# frozen_string_literal: true

# Copyright © 2015-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module EBS
  class MenuEntry < Liquid::Drop
    def initialize
      super()
      @files = []
    end

    attr_accessor :title, :type, :model, :id, :offsets, :modes, :captions,
                  :files
    attr_writer :linkpath

    def linkpath
      if @type == :menu
        "#menu#{@id}"
      else
        @linkpath
      end
    end
  end
end
