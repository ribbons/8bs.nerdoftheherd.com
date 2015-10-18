# This file is part of the 8BS Online Conversion.
# Copyright © 2015 by the authors - see the AUTHORS file for details.
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
#
# You should have received a copy of the GNU General Public License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.

module EBS
  class MenuEntry < Liquid::Drop
    def initialize(disc, linkpaths)
      @disc = disc
      @linkpaths = linkpaths
    end

    attr_accessor :title, :type, :id
    attr_reader :paths

    def paths=(paths)
      @paths = []

      paths.each do |path|
        @paths << @disc.canonicalise_path(path)
      end

      @linkpath = Jekyll::Utils.slugify(@paths[0])

      # Make the path unique if it collides with an existing one
      if @linkpaths.key?(@linkpath)
        suffix = 1
        suffix += 1 while @linkpaths.key?(@linkpath + '-' + suffix.to_s)
        @linkpath << '-' + suffix.to_s
      end

      @linkpaths[@linkpath] = 1
    end

    def linkpath
      if @type == :menu
        return '#menu' + @id.to_s
      else
        return 'content/' + @linkpath + '/'
      end
    end

    def content
      content = []

      @paths.each do |path|
        content << @disc.file(path).content
      end

      content
    end
  end
end
