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
  module Output
    class FileListPage < Jekyll::Page
      def initialize(site, dir, disc, fileitems)
        @site = site
        @base = site.source
        @dir = dir
        @name = 'index.html'

        process(@name)
        read_yaml(File.join(@base, '_layouts'), 'file_list.html')

        files = [[], []]

        fileitems.each do |item|
          file = item.files[0]

          files[file.side.zero? ? 0 : 1] << {
            'path' => item.path,
            'dir' => file.dir,
            'name' => file.name,
            'title' => item.title != file.path ? item.title : nil
          }
        end

        files.pop if files[1].empty?

        files.each do |side|
          side.sort_by! { |f| f['dir'] + f['name'] }
        end

        data['title'] += disc.issue.number.to_s
        data['title'] += " Disc #{disc.number}" if disc.issue.discs.count > 1

        data['navchain'] = disc.navchain + [{ 'navtitle' => 'File list' }]
        data['files'] = files
      end
    end
  end
end
