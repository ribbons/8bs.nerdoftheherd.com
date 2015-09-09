module Jekyll
  class IndexPage < Page
    def initialize(site, base, dir, issues)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(base, '_layouts'), 'index.html')

      data['issues'] = issues
    end
  end
end
