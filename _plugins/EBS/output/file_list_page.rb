# frozen_string_literal: true

# Copyright © 2019-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module EBS
  module Output
    class FileListPage < Jekyll::PageWithoutAFile
      def initialize(site, dir, disc, fileitems)
        super(site, site.source, dir, 'index.html')

        self.data = {
          'files' => self.class.prepare_files(fileitems),
          'navchain' => disc.navchain + [{ 'navtitle' => 'File list' }],
          'layout' => 'file_list',
          'title' => "File list for 8-Bit Software Issue #{disc.issue.number}",
        }

        data['title'] += " Disc #{disc.number}" if disc.issue.discs.count > 1
      end

      def self.prepare_files(fileitems)
        files = [[], []]

        fileitems.each do |item|
          file = item.files[0][-1]

          files[file.side.zero? ? 0 : 1] << {
            'path' => item.path,
            'dir' => file.dir,
            'name' => file.name,
            'title' => item.title == file.path ? nil : item.title,
          }
        end

        files.pop if files[1].empty?

        files.each do |side|
          side.sort_by! { |f| f['dir'] + f['name'] }
        end
      end
    end
  end
end
