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

          map_content(entry, entry.files)
        end
      end
    end

    private

    def map_content(entry, files)
      linkpath = 'content/' + Jekyll::Utils.slugify(files[0].path)

      # Make the path unique if it collides with an existing one
      if @paths.key?(linkpath)
        suffix = 1
        suffix += 1 while @paths.key?(linkpath + '-' + suffix.to_s)
        linkpath << '-' + suffix.to_s
      end

      @paths[linkpath] = 1
      entry.linkpath = linkpath

      arcfiles = files.clone unless entry.arcpaths.nil?

      unless entry.arcpaths.nil?
        files = []

        arcfiles.each do |arcfile|
          archive = Archive.from_file(arcfile, entry.arcfix)

          entry.arcpaths.each do |arcpath|
            file = archive.file(arcpath)
            files << file unless file.nil?
          end
        end
      end

      item = ContentItem.new(@infodisc, files, entry)

      @site.pages << Output::ContentPage.new(
        @site, File.join(@infodisc.path, linkpath), @infodisc, item, :default
      )

      if entry.type == :basic || entry.type == :run
        unless entry.arcpaths.nil?
          @site.static_files << Output::DiscFile.new(
            @site, File.join(@infodisc.path, linkpath), entry.title, arcfiles
          )
        end

        @site.static_files << Output::BootstrapBasicFile.new(
          @site, File.join(@infodisc.path, linkpath), item
        )
      end

      return unless entry.type == :basic

      @site.pages << Output::ContentPage.new(
        @site, File.join(@infodisc.path, linkpath, 'list'), @infodisc,
        item, :list
      )
    end
  end
end
