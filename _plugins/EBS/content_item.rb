# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2019-2020 by the authors - see the AUTHORS file for details.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module EBS
  class ContentItem < Liquid::Drop
    def initialize(parent, path, files, entry)
      super()

      @parent = parent
      @files = files

      @title = entry&.title&.chomp('.') || files[0].path
      @offsets = entry&.offsets
      @modes = entry&.modes
      @path = parent.path + path
      @imagepath = entry&.imagepath || parent.imagepath
      @model = entry&.model

      @type = entry&.type || files[0].type
    end

    attr_reader :type, :title, :offsets, :modes, :files, :path, :model,
                :imagepath

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
                     extract_section(file.content, @offsets, idx)
                   elsif @type == :basic
                     file.parsed.to_html
                   elsif @type == :mode7
                     trim_scroller(file.content, file.loadaddr)
                   else
                     file.content
                   end
      end

      content
    end

    private

    MODE7_SCREEN_SIZE = 25 * 40

    def trim_scroller(content, loadaddr)
      # The first four bytes are the start and end locations of the text data
      textstart = (content.getbyte(1) << 8 | content.getbyte(0)) - loadaddr
      textend = (content.getbyte(3) << 8 | content.getbyte(2)) -
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
