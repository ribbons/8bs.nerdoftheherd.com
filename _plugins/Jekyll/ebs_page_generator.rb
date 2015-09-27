module Jekyll
  class EBSPageGenerator < Generator
    safe true

    def generate(site)
      issues = EBS::Issue.all_issues

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
                site.pages << ContentPage.new(site, File.join(disc.path, entry.linkpath, 'list'), disc, entry, :list)
              end
            end
          end
        end
      end
    end
  end
end
