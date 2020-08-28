# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2015-2020 by the authors - see the AUTHORS file for details.
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
    class EmulateDiscPage < Jekyll::Page
      def initialize(site, dir, disc)
        @site = site
        @base = site.source
        @dir = dir
        @name = 'index.html'

        process(@name)
        read_yaml(File.join(@base, '_layouts'), 'emulate_disc.html')

        issue = disc.issue

        data['title'] += issue.number.to_s
        data['title'] += " Disc #{disc.number}" if issue.discs.count > 1

        data['disc'] = disc
        data['navchain'] = disc.navchain + [{ 'navtitle' => 'Emulate' }]
      end
    end
  end
end
