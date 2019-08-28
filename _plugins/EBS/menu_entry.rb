# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2015-2019 by the authors - see the AUTHORS file for details.
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
  class MenuEntry < Liquid::Drop
    def initialize(issdisc)
      @issdisc = issdisc
    end

    attr_accessor :title, :type, :model, :id, :offsets, :modes, :captions,
                  :arcpaths, :arcfix
    attr_reader :paths
    attr_writer :linkpath

    def paths=(paths)
      @paths = paths.map do |path|
        @issdisc.disc.canonicalise_path(path)
      end
    end

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

    def linkpath
      if @type == :menu
        '#menu' + @id.to_s
      else
        @linkpath + '/'
      end
    end

    def imagepath
      if @arcpaths.nil?
        @issdisc.imagepath
      else
        '/' + @issdisc.path + '/' + linkpath + 'emulate.ssd'
      end
    end

    def generate_disc
      files = []

      @paths.each do |path|
        file = @issdisc.disc.file(path)
        archive = Archive.from_file(file, @arcfix)
        files.concat(archive.files)
      end

      @issdisc.disc.generate_disc(@paths[0], files)
    end

    def bootstrap_basic
      splitpath = if @arcpaths.nil?
                    @paths[0].split('.', 3)
                  else
                    @issdisc.disc.canonicalise_path(@arcpaths[0]).split('.', 3)
                  end

      basic = 'OSCLI("DRIVE ' + splitpath[0][1] + "\")\n" \
      'OSCLI("DIR ' + splitpath[1] + "\")\n"

      if @type == :basic
        basic + 'CHAIN "' + splitpath[2] + '"'
      else
        basic + 'OSCLI("RUN ' + splitpath[2] + '")'
      end
    end

    def content
      content = []

      @paths.each_with_index do |path, idx|
        file = @issdisc.disc.file(path)

        if @arcpaths.nil?
          content << if !@offsets.nil?
                       extract_section(file.content, @offsets, idx)
                     elsif @type == :mode7
                       trim_scroller(file.content, file.loadaddr)
                     else
                       file.content
                     end
        else
          archive = Archive.from_file(file, @arcfix)

          @arcpaths.each do |arcpath|
            filecontent = archive.file(arcpath)
            content << filecontent unless filecontent.nil?
          end
        end
      end

      content
    end

    MODE7_SCREEN_SIZE = 25 * 40

    private

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
