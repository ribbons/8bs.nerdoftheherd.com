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
    class ContentPage < Jekyll::Page
      def initialize(site, dir, disc, item, action)
        @site = site
        @base = site.source
        @dir = dir

        @name = 'index.html'

        template = case item.type
                   when :mode0
                     'content_mode0'
                   when :mode7
                     'content_mode7'
                   when :basic
                     if action == :list
                       'content_basic_list'
                     else
                       'content_basic'
                     end
                   when :ldpic, :screendump, :scrload
                     'content_image'
                   when :run
                     'content_runnable'
                   else
                     throw "Unknown item type: #{item.type}"
                   end

        process(@name)
        read_yaml(File.join(@base, '_layouts'), "#{template}.html")

        if data['title']
          data['title'].sub!('$title', item.title)
        else
          data['title'] = item.title
        end

        data['disc'] = disc
        data['item'] = item

        data['navchain'] = item.navchain
        data['navchain'].push('navtitle' => data['action']) if data['action']
      end
    end
  end
end
