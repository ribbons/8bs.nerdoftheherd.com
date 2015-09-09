module EBS
  class Menu < Liquid::Drop
    def initialize
      @entries = []
    end

    attr_accessor :title, :id, :entries
  end
end
