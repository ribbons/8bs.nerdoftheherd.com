module EBS
  module TrimScroller
    def trim_scroller(input)
      # Chop off scroller code
      input[256..-1]
    end
  end

  Liquid::Template.register_filter(EBS::TrimScroller)
end
