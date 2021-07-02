# frozen_string_literal: true

# Copyright © 2015-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module EBS
  module Output
    class ContentPage < Jekyll::PageWithoutAFile
      def initialize(site, dir, disc, item, extra)
        super(site, site.source, dir, 'index.html')

        self.data = {
          'disc' => disc,
          'item' => item,
          'navchain' => item.navchain,
          'title' => item.title,
        }

        case item.type
        when :mode0
          data['layout'] = 'content_mode0'
        when :mode7
          data['layout'] = 'content_mode7'
          data['includejs'] = '/common/script/mode7.js'
        when :basic
          if extra == :list
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
        when :archive
          data['layout'] = 'file_list'
          data['files'] = FileListPage.prepare_files(extra)
          data['title'] += ' File list'
        else
          throw "Unknown item type: #{item.type}"
        end
      end
    end
  end
end
