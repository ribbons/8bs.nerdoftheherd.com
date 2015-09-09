module Jekyll
  class DiscIndexPage < Page
    def initialize(site, dir, disc, menugroup)
      @site = site
      @base = site.source
      @dir = dir
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(@base, '_layouts'), 'disc_index.html')

      issue = disc.issue

      data['title'] += issue.number
      data['title'] += ' Disc ' + disc.number if issue.discs.count > 1

      data['disc'] = disc
      data['menugroup'] = menugroup
    end
  end
end
