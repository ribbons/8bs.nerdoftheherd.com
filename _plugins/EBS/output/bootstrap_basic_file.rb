# frozen_string_literal: true

# Copyright © 2019-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module EBS
  module Output
    class BootstrapBasicFile < Jekyll::StaticFile
      def initialize(site, dir, item)
        super(site, site.source, dir, 'emulate.bas')
        @item = item
      end

      def write(dest)
        dest_path = destination(dest)

        FileUtils.mkdir_p(File.dirname(dest_path))
        FileUtils.rm(dest_path) if File.exist?(dest_path)
        File.write(dest_path, generate_basic)

        true
      end

      private

      def generate_basic
        basic = "OSCLI(\"DRIVE #{@item.files[0][-1].side}\")\n" \
                "OSCLI(\"DIR #{@item.files[0][-1].dir}\")\n"

        if @item.type == :basic
          "#{basic}CHAIN \"#{@item.files[0][-1].name}\"\n"
        else
          "#{basic}OSCLI(\"RUN #{@item.files[0][-1].name}\")\n"
        end
      end
    end
  end
end
