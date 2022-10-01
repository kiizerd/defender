module Arbor
  class NodeIsRoot < StandardError; end
  class NodeNameNotUnique < StandardError; end
  class Node
    @@next_id = 1

    attr_reader :children, :parent, :name

    def initialize(opts = {})
      @id = opts.fetch(:id, @@next_id)
      @@next_id = [@id + 1, @@next_id].max

      # Properties shared by all nodes
      @name     = opts.fetch(:name, default_name)
      @parent   = extract_parent(opts)
      @children = extract_children(opts)
    end

    # Adds a child if it will fit in children collection
    # returns new_child if successful, otherwise returns false
    def add_child(new_child)
      # raise("NotANode") unless new_child.is_a? Arbor::Node
      raise("NotANode") unless new_child.class <= Arbor::Node

      # no-op if new_child already a child
      is_childs_parent = new_child.parent.name == @name
      has_childs_key   = @children.has_key?(new_child.name)
      return -1 if has_childs_key && is_childs_parent

      # Set new_childs parent and return if child already in @children
      new_child.update_parent(self) unless is_childs_parent
      return 0 if has_childs_key

      @children[new_child.name] = new_child      
    end

    # Effectively deletes the child
    def remove_child(child_name)
      raise("NotMyChild") unless @children.has_key? child_name
      # raise("DontDoThat") if child_new_parent.name == @name

      # Get and remove child,
      # If not reassigning child parent,
      # return result of removing childs parent
      child = @children[child_name]
      @children.delete(child_name)
      return child.remove_parent

      # Move this to a reassign_parent method
      # # Assign new child parent if it is subclass of node
      # raise(NotANode) unless child_new_parent.class <= Arbor::Node
      # child.update_parent(child_new_parent)
      # child_new_parent.add_child(child)
    end

    # empty callback function
    def child_name_updated(child:, new_name:, old_name:)
      puts :child_name_updated
    end

    # Updates @parent to given variable if valid
    # returns -1 if new_parent is valid but already @parent
    # returns  0 if parent changed but self is already child of new_parent
    # returns result of add_child(self) on new_parent
    def update_parent(new_parent)
      # raise("NotANode") unless new_parent.is_a? Arbor::Node
      raise("NotANode") unless new_parent.class <= Arbor::Node

      # If new_parent is same as current
      return -1 if @parent && @parent.name == new_parent.name
      @parent = new_parent

      # Add self to new parents children if not present
      name_will_be_unique = !new_parent.children.has_key?(@name)
      return 0 unless name_will_be_unique

      new_parent.add_child(self)
    end

    def remove_parent
      return -1 if !@parent

      @parent = false
      @parent.remove_child(@name) if @parent.children[@name]
      self
    end

    def update_name(new_name)
      # Updates name and returns if parent is false, meaning Node is root
      return (@name = new_name) if !parent

      old_name = @name
      new_name_is_unique = siblings.none? { |c| c.name == new_name }
      return false unless new_name_is_unique

      @name = new_name
      @parent.child_name_updated(child: self, new_name: new_name, old_name: old_name)
      self
    end

    def siblings
      parent ? parent.children : raise(Arbor::NodeIsRoot)
    end

    def default_name
      "#{self.class.name}_#{@id}"
    end

    def serialize
      { name: @name, node_class: self.class.name, parent: @parent }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    private
    
    def extract_parent(options)
      parent = options.fetch(:parent, false)
      return false unless parent && parent.is_a?(Arbor::Node)

      parent
    end

    # Extracts children value from initialization options
    #
    # Returns empty hash if given hash is invalid
    def extract_children(options)
      children = options.fetch(:children, {})
      return Hash.new unless [Hash, Array].include?(children.class)

      children_to_hash(children)
    end

    def children_to_hash(children)
      children_array = children.is_a?(Hash) ? children.values : children
      nodes = children_array.uniq.filter { |child| child.is_a? Arbor::Node }

      # Map nodes to a hash with their names as keys
      # and set the parent of each node to self
      nodes.map { |n| [n.name, n.update_parent(self)] }.to_h
    end
  end
end
