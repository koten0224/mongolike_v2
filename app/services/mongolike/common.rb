module Mongolike
  module Common
    private

    def value_transfer(child)
      case child.cls
      when 'Integer'
        child.value.to_i
      when 'String'
        child.value
      when 'Hash'
        Mongolike::Hash.new(child, body: @mapping["#{child.class}#{child.id}"], mapping: @mapping)
      when 'Array'
        Mongolike::Array.new(child, body: @mapping["#{child.class}#{child.id}"], mapping: @mapping)
      when 'TrueClass'
        true
      when 'FalseClass'
        false
      when 'NilClass'
        nil
      end
    end

    def filted_value(value)
      if value.class.in? [String, Integer]
        value
      end
    end
  end
end