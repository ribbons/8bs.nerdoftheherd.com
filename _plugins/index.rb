module Jekyll
  class EmulateDiscPage < Page
    def initialize(site, base, dir, disc)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(base, '_layouts'), 'emulate_disc.html')

      issue = disc.issue

      data['title'] += issue.number
      data['title'] += ' Disc ' + disc.number if issue.discs.count > 1

      data['disc'] = disc
    end
  end

  class IndexPage < Page
    def initialize(site, base, dir)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(base, '_layouts'), 'index.html')

      issues = EBS::Issue.all_issues

      issues.each do |issue|
        issue.discs.each do |disc|
          site.pages << EmulateDiscPage.new(site, site.source, disc.path, disc)
        end
      end

      data['issues'] = issues
    end
  end

  class IndexPageGenerator < Generator
    safe true

    def generate(site)
      site.pages << IndexPage.new(site, site.source, '')
    end
  end
end
