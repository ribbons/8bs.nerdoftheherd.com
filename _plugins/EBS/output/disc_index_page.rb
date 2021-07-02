# frozen_string_literal: true

# Copyright © 2015-2020 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module EBS
  module Output
    class DiscIndexPage < Jekyll::PageWithoutAFile
      def initialize(site, dir, disc)
        super(site, site.source, dir, 'index.html')

        issue = disc.issue

        self.data = {
          'disc' => disc,
          'includejs' => '/common/script/menu.js',
          'navchain' => disc.navchain,
          'layout' => 'disc_index',
          'title' => "8-Bit Software Issue #{issue.number}",
        }

        data['title'] += " Disc #{disc.number}" if issue.discs.count > 1
      end
    end
  end
end
