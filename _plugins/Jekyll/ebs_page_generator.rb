# This file is part of the 8BS Online Conversion.
# Copyright © 2015-2016 by the authors - see the AUTHORS file for details.
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

module Jekyll
  class EBSPageGenerator < Generator
    safe true

    def generate(site)
      issues = EBS::Issue.all_issues

      # Ensure folders for files generated outside Jekyll exist
      site.config['keep_files'].each do |dir|
        FileUtils.mkpath(site.in_dest_dir(dir))
      end

      site.pages << IndexPage.new(site, issues)

      issues.each do |issue|
        issue.discs.each do |disc|
          site.pages << DiscIndexPage.new(site, disc.path, disc)
          site.pages << EmulateDiscPage.new(site, File.join(disc.path, 'emulate'), disc)

          disc.menus.each do |menu|
            menu.entries.each do |entry|
              if entry.type != :menu
                site.pages << ContentPage.new(site, File.join(disc.path, entry.linkpath), disc, entry, :default)
              end

              if entry.type == :basic
                site.pages << ContentPage.new(site, File.join(disc.path, entry.linkpath), disc, entry, :bootstrap)
              end

              if entry.type == :basic || entry.type == :exec
                site.pages << ContentPage.new(site, File.join(disc.path, entry.linkpath, 'list'), disc, entry, :list)
              end
            end
          end
        end
      end
    end
  end
end
