module Mongolike
  class Array < Array
    include Common
    attr_reader :was
    def initialize(parent, body: [], mapping: ::Hash.new{|h,k|h[k]=[]})
      @parent = parent
      @owner = parent
      while @owner.try(:parent)
        @owner = @owner.parent
      end
    end
  end
end