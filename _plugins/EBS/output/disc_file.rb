# frozen_string_literal: true

# Copyright © 2015-2022 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module EBS
  module Output
    class DiscFile < Jekyll::StaticFile
      def initialize(site, dir, title, files)
        super(site, site.source, dir, 'emulate.ssd')

        @title = title
        @files = files
      end

      def write(dest)
        dest_path = destination(dest)

        FileUtils.mkdir_p(File.dirname(dest_path))
        File.write(dest_path, generate_disc)

        true
      end

      private

      def generate_disc
        files = @files.flat_map { |f| f.parsed.files }
        BBC::DfsDisc.generate_disc(@title, files)
      end
    end
  end
end
