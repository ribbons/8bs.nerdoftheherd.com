# frozen_string_literal: true

# Copyright © 2015-2022 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative 'arcer18_file'
require_relative 'arcver30_file'
require_relative 'bbc_native'

module BBC
  class BBCFile
    PARSETYPES = [
      BasicFile,
      Dispmo7File,
      Arcer18File,
      Arcver30File,
      ArcFile,
      AbzFile,
    ].freeze

    def initialize(side, dir, name, loadaddr, execaddr, content, tweaks = nil)
      @side = side
      @dir = dir
      @name = name
      @loadaddr = tweaks&.fetch(:loadaddr, nil) || loadaddr
      @execaddr = tweaks&.fetch(:execaddr, nil) || execaddr
      @position = 0
      @tweaks = tweaks

      byteranges = tweaks&.fetch(:byteranges, nil)

      if byteranges.nil?
        @content = content
        return
      end

      @content = String.new

      (0...byteranges.length).step(2).each do |idx|
        finish = byteranges[idx + 1] || content.bytesize
        @content << content[byteranges[idx]...finish]
      end
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
      @position += value.bytesize
      value
    end

    def parsed
      if @parsedfile.nil?
        parser = tweaks&.fetch(:parser, nil)

        if parser.nil?
          PARSETYPES.each do |type|
            @parsedfile = type.parse(self)
            @position = 0

            break unless @parsedfile.nil?
          end
        else
          @parsedfile = Object.const_get("BBC::#{parser}").parse(self)
        end
      end

      @parsedfile
    end

    def type
      case parsed
      when ArchiveFile
        :archive
      when BasicFile
        :basic
      when Mode7File
        :mode7
      end
    end

    def <<(item)
      @parsedfile << item.parsed unless parsed.nil?
      @content << item.content
    end
  end
end
