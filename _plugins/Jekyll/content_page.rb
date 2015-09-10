module Jekyll
  class ContentPage < Page
    def initialize(site, dir, disc, entry)
      @site = site
      @base = site.source
      @dir = dir
      @name = 'index.html'

      case entry.type
      when :mode0
        template = 'content_mode0'
      when :mode7
        template = 'content_mode7'
      when :runbasic, :listbasic
        template = 'content_basic'
      when :run, :ldpic
        template = 'content_runnable'
      else
        throw 'Unknown entry type: ' + entry.type.to_s
      end

      process(@name)
      read_yaml(File.join(@base, '_layouts'), template + '.html')

      data['title'] = entry.title
      data['disc'] = disc
      data['entry'] = entry
    end
  end
end
