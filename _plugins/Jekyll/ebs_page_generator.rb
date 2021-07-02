# frozen_string_literal: true

# Copyright © 2015-2019 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module Jekyll
  class EBSPageGenerator < Generator
    safe true

    def generate(site)
      # Ensure folders for files generated outside Jekyll exist
      site.config['keep_files'].each do |dir|
        FileUtils.mkpath(site.in_dest_dir(dir))
      end

      issues = EBS::Issue.all_issues(site)
      site.pages << EBS::Output::IndexPage.new(site, issues)

      issues.each do |issue|
        issue.discs.each do |disc|
          site.pages << EBS::Output::DiscIndexPage.new(site, disc.path, disc)

          site.pages << EBS::Output::EmulateDiscPage.new(
            site, File.join(disc.path, 'emulate'), disc
          )
        end
      end
    end
  end
end
