module Jekyll
  class EBSPageGenerator < Generator
    safe true

    def generate(site)
      issues = EBS::Issue.all_issues

      site.pages << IndexPage.new(site, issues)

      issues.each do |issue|
        issue.discs.each do |disc|
          site.pages << DiscIndexPage.new(site, disc.path, disc, disc.menugroup)
          site.pages << EmulateDiscPage.new(site, File.join(disc.path, 'emulate'), disc)
        end
      end
    end
  end
end
