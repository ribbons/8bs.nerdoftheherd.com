module Jekyll
  class EBSPageGenerator < Generator
    safe true

    def generate(site)
      issues = EBS::Issue.all_issues

      site.pages << IndexPage.new(site, site.source, '', issues)

      issues.each do |issue|
        issue.discs.each do |disc|
          site.pages << DiscIndexPage.new(site, site.source, disc.path, disc, disc.menugroup)
          site.pages << EmulateDiscPage.new(site, site.source, disc.path + '/emulate', disc)
        end
      end
    end
  end
end
