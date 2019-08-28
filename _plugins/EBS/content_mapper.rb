# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2019 by the authors - see the AUTHORS file for details.
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
  class ContentMapper
    def initialize(site, infodisc)
      @site = site
      @infodisc = infodisc

      @paths = {}
    end

    def map_menus(menus)
      menus.each do |menu|
        menu.entries.each do |entry|
          next if entry.type == :menu

          map_content(entry, entry.paths)
        end
      end
    end

    private

    def map_content(entry, paths)
      linkpath = 'content/' + Jekyll::Utils.slugify(paths[0])

      # Make the path unique if it collides with an existing one
      if @paths.key?(linkpath)
        suffix = 1
        suffix += 1 while @paths.key?(linkpath + '-' + suffix.to_s)
        linkpath << '-' + suffix.to_s
      end

      @paths[linkpath] = 1

      @site.pages << Output::ContentPage.new(
        @site, File.join(@infodisc.path, linkpath), @infodisc, entry, :default
      )

      if entry.type == :basic || entry.type == :run
        unless entry.arcpaths.nil?
          @site.static_files << Output::DiscFile.new(
            @site, File.join(@infodisc.path, linkpath), entry
          )
        end

        @site.pages << Output::ContentPage.new(
          @site, File.join(@infodisc.path, linkpath), @infodisc, entry,
          :bootstrap
        )
      end

      if entry.type == :basic
        @site.pages << Output::ContentPage.new(
          @site, File.join(@infodisc.path, linkpath, 'list'), @infodisc,
          entry, :list
        )
      end

      entry.linkpath = linkpath
    end
  end
end
