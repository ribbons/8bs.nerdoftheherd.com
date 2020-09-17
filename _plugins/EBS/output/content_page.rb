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
    class ContentPage < Jekyll::PageWithoutAFile
      def initialize(site, dir, disc, item, action)
        super(site, site.source, dir, 'index.html')

        self.data = {
          'disc' => disc,
          'item' => item,
          'navchain' => item.navchain,
          'title' => item.title
        }

        case item.type
        when :mode0
          data['layout'] = 'content_mode0'
        when :mode7
          data['layout'] = 'content_mode7'
          data['includejs'] = '/common/script/mode7.js'
        when :basic
          if action == :list
            data['layout'] = 'content_basic_list'
            data['includejs'] = '/common/script/mode7.js'
            data['title'] += ' - Listing'
            data['navchain'].push('navtitle' => 'Listing')
          else
            data['layout'] = 'content_basic'
            data['includejs'] = '/common/script/emulate.js'
          end
        when :ldpic, :screendump, :scrload
          data['layout'] = 'content_image'
        when :run
          data['layout'] = 'content_runnable'
          data['includejs'] = '/common/script/emulate.js'
        else
          throw "Unknown item type: #{item.type}"
        end
      end
    end
  end
end
