# frozen_string_literal: true

# Copyright © 2019-2022 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module EBS
  class ContentItem < Liquid::Drop
    def initialize(parent, path, files, entry)
      super()

      @parent = parent
      @files = files

      @title = entry&.title&.chomp('.') || files[0][-1].path
      @offsets = entry&.offsets
      @modes = entry&.modes
      @path = path
      @imagepath = parent.imagepath
      @model = entry&.model
      @captions = entry&.captions

      @type = entry&.type || files[0][-1].type
    end

    attr_reader :type, :title, :offsets, :modes, :files, :path, :model,
                :captions
    attr_accessor :imagepath

    def typestr
      @type.id2name
    end

    def modelstr
      case @model
      when :modelb
        'b'
      when :master128
        'master'
      end
    end

    def navchain
      @parent.navchain + [self]
    end

    def navtitle
      @title
    end

    def content
      content = []

      @files.each_with_index do |file, idx|
        content << if !@offsets.nil?
                     extract_section(file[-1].content, @offsets, idx)
                   elsif @type == :basic
                     file[-1].parsed.to_html
                   elsif @type == :mode7
                     trim_scroller(file[-1].content, file[-1].loadaddr)
                   else
                     file[-1].content
                   end
      end

      content
    end

    private

    MODE7_SCREEN_SIZE = 25 * 40

    def trim_scroller(content, loadaddr)
      # The first four bytes are the start and end locations of the text data
      textstart = ((content.getbyte(1) << 8) | content.getbyte(0)) - loadaddr
      textend = ((content.getbyte(3) << 8) | content.getbyte(2)) -
                loadaddr + MODE7_SCREEN_SIZE - 1

      # Chop off scroller code
      content[textstart..textend]
    end

    def extract_section(content, offsets, index)
      offind = index * 2
      content[offsets[offind]..offsets[offind] + offsets[offind + 1] - 1]
    end
  end
end
