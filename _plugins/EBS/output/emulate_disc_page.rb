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
    class EmulateDiscPage < Jekyll::PageWithoutAFile
      def initialize(site, dir, disc)
        super(site, site.source, dir, 'index.html')

        issue = disc.issue

        self.data = {
          'disc' => disc,
          'includejs' => '/common/script/emulate.js',
          'navchain' => disc.navchain + [{ 'navtitle' => 'Emulate' }],
          'layout' => 'emulate_disc',
          'page' => 'emulate_disc',
          'title' => "8-Bit Software Issue #{issue.number}"
        }

        data['title'] += " Disc #{disc.number}" if issue.discs.count > 1
      end
    end
  end
end
