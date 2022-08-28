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
                     file[-1].parsed.screendata
                   else
                     file[-1].content
                   end
      end

      content
    end

    private

    def extract_section(content, offsets, index)
      offind = index * 2
      content[offsets[offind]..offsets[offind] + offsets[offind + 1] - 1]
    end
  end
end
