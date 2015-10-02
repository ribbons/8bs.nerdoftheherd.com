module Jekyll
  class EmulateDiscPage < Page
    def initialize(site, dir, disc)
      @site = site
      @base = site.source
      @dir = dir
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(@base, '_layouts'), 'emulate_disc.html')

      issue = disc.issue

      data['title'] += issue.number.to_s
      data['title'] += ' Disc ' + disc.number if issue.discs.count > 1

      data['disc'] = disc
    end
  end
end
