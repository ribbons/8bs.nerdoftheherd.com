module EBS
  module TrimScroller
    # The scrolling text is loaded at 0x1900 and run from 0x1904
    LOAD_ADDRESS = 0x1900
    SCREEN_SIZE = 25 * 40

    def trim_scroller(input)
      # The first four bytes are the start and end locations of the text data
      textstart = (input.getbyte(1) << 8 | input.getbyte(0)) - LOAD_ADDRESS
      textend = (input.getbyte(3) << 8 | input.getbyte(2)) - LOAD_ADDRESS + SCREEN_SIZE

      # Chop off scroller code
      input[textstart..textend]
    end
  end

  Liquid::Template.register_filter(EBS::TrimScroller)
end
