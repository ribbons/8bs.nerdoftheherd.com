# frozen_string_literal: true

# Copyright © 2015-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative 'arcer18_file'
require_relative 'arcver30_file'
require_relative 'bbc_native'

module BBC
  class BBCFile
    PARSETYPES = [
      BasicFile,
      Arcer18File,
      Arcver30File,
      ArcFile,
    ].freeze

    def initialize(side, dir, name, loadaddr, execaddr, content, tweaks = nil)
      @side = side
      @dir = dir
      @name = name
      @loadaddr = tweaks&.fetch(:loadaddr, nil) || loadaddr
      @execaddr = tweaks&.fetch(:execaddr, nil) || execaddr
      @content = content
      @position = 0
      @tweaks = tweaks
    end

    attr_reader :side, :dir, :name, :loadaddr, :execaddr, :content, :tweaks

    def path
      ":#{@side}.#{@dir}.#{@name}"
    end

    def length
      @content.bytesize - @position
    end

    def empty?
      length.zero?
    end

    def shift(elements = 1)
      value = @content.byteslice(@position, elements)
      @position += elements
      value
    end

    def parsed
      PARSETYPES.each do |type|
        break unless @parsedfile.nil?

        @parsedfile = type.parse(self)
        @position = 0
      end

      @parsedfile
    end

    def type
      case parsed
      when ArchiveFile
        :archive
      when BasicFile
        :basic
      end
    end

    def <<(item)
      @parsedfile << item.parsed unless parsed.nil?
      @content << item.content
    end
  end
end
