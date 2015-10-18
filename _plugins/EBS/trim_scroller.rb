module EBS
  module TrimScroller
    # The scrolling text is loaded at 0x1900 and run from 0x1904
    LOAD_ADDRESS = 0x1900

    def trim_scroller(input)
      # The first two bytes are the start location of the text data
      textstart = (input.getbyte(1) << 8 | input.getbyte(0)) - LOAD_ADDRESS

      # Chop off scroller code
      input[textstart..-1]
    end
  end

  Liquid::Template.register_filter(EBS::TrimScroller)
end
