# frozen_string_literal: true

# Copyright © 2015-2020 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module EBS
  module Output
    class IndexPage < Jekyll::PageWithoutAFile
      def initialize(site, issues)
        super(site, site.source, '', 'index.html')

        self.data = {
          'issues' => issues,
          'layout' => 'index',
          'title' => '8-Bit Software Magazines Index',
        }
      end
    end
  end
end
