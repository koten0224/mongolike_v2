module Mongolike
  class Hash < Hash
    include Common
    attr_reader :was
    def self.pass_hash(parent, hash)
      body = new(parent)
      hash.each do |k,v|
        body[k]=v
      end
      body
    end

    def initialize(parent, body: [], mapping: ::Hash.new{|h,k|h[k]=[]})
      @parent = parent
      @owner = parent
      while @owner.try(:parent)
        @owner = @owner.parent
      end
      if mapping.blank?
        parent_mapping = {"#{@parent.class}#{@parent.id}" => @parent}
        Setting.where(owner: @owner).each do |child|
          mapping["#{child.parent_type}#{child.parent_id}"] << child
          parent_mapping["#{child.class}#{child.id}"] = child
        end
        key = "#{@parent.class}#{@parent.id}"
        body = mapping[key]
        mapping.values.each do |children|
          children.each do |child|
            child.owner = @owner
            child.parent = parent_mapping["#{child.parent_type}#{child.parent_id}"]
          end
        end
      end
      @mapping = mapping
      @body = body
      # debugger
      body.each do |child|
        self[child.key] = value_transfer(child)
      end

      @was = clone
    end

    def compare(body=self)
      del_keys = @was.keys - body.keys
      add_keys = body.keys - @was.keys
      both_keys = @was.keys & body.keys
      changed_keys = both_keys.select{|k| @was[k] != body[k]}
      {
        del_keys: del_keys,
        add_keys: add_keys,
        changed_keys: changed_keys
      }
    end

    def save(body=self)
      compare_result = compare(body)
      del_children = Setting.where(parent: @parent, key: compare_result[:del_keys])
      while del_children.length > 0
        del_children_exec = del_children
        del_children = Setting.where(parent: del_children.select{|c|c.cls.in? ['Hash', 'Array']}.pluck(:id))
        del_children_exec.delete_all
      end
      compare_result[:add_keys].each do |key|
        child = Setting.create(owner: @owner, parent: @parent, key: key, value: filted_value(body[key]), cls: body[key].class)
        check_child(child, body)
      end
      compare_result[:changed_keys].each do |key|
        child = Setting.find_by(parent_type: @parent.class,parent_id: @parent.id,key: key)
        child.update(value: filted_value(body[key]), cls: body[key].class)
        check_child(child, body)
      end
      @was = clone
    end

    def check_child(child, body=self)
      key = child.key
      child.parent = @parent
      child.owner = @owner
      if body[key].class.in? Mongolike::CONTAINERS
        body[key].save
      elsif body[key].is_a? Hash
        body[key] = Mongolike::Hash.pass_hash(child, body[key])
        body[key].save
      elsif body[key].is_a? Array
        body[key] = Mongolike::Array.pass_array(child, body[key])
        body[key].save
      end
    end
  end
end