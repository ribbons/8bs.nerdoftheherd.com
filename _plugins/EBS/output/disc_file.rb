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
  module Output
    class DiscFile < Jekyll::StaticFile
      def initialize(site, dir, title, files)
        @site = site
        @base = site.source
        @dir = dir
        @title = title
        @files = files

        @name = 'emulate.ssd'
      end

      def write(dest)
        dest_path = destination(dest)

        FileUtils.mkdir_p(File.dirname(dest_path))
        FileUtils.rm(dest_path) if File.exist?(dest_path)
        File.write(dest_path, generate_disc)

        true
      end

      private

      def generate_disc
        files = []

        @files.each do |file|
          archive = Archive.from_file(file, @arcfix)
          files.concat(archive.files)
        end

        @files[0].disc.generate_disc(@title, files)
      end
    end
  end
end
