# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2015-2021 by the authors - see the AUTHORS file for details.
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

module BBC
  class BBCFile
    def initialize(side, dir, name, loadaddr, execaddr, content)
      @side = side
      @dir = dir
      @name = name
      @loadaddr = loadaddr
      @execaddr = execaddr
      @content = content
      @position = 0
    end

    attr_reader :side, :dir, :name, :loadaddr, :execaddr, :content

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
      @parsedfile = BasicFile.parse(self) if @parsedfile.nil?
      @parsedfile
    end

    def type
      case parsed
      when BasicFile
        :basic
      end
    end
  end
end
