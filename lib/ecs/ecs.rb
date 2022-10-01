module ECS
  class NotAComponentError < StandardError; end

  class Entity
    @default_components = {}
    @@next_id = 1

    # Resets the default components for each class that inherites Entity.
    def self.inherited(sub)
      super
      sub.instance_variable_set(:@default_components, {})
    end

    def self.component(component, defaults = {})
      @default_components[component] = defaults
    end

    # Creates a tag Component. If the tag already exists, return it.
    #
    # name - The string or symbol name of the component.
    #
    # Returns a class with subclass Draco::Component.
    def self.Tag(name)
      ECS::Tag(name)
    end
    
    class << self
      attr_reader :default_components
    end

    attr_reader :id, :components

    def initialize(args = {})
      @id = args.fetch(:id, @@next_id)      
      @@next = [@id + 1, @@next_id].max
      @subscriptions = []

      setup_components(args)
      after_initialize
    end

    def setup_components(args)
      @components = ComponentStore.new(self)

      self.class.default_components.each do |component, default_args|
        component_name = ECS.underscore(component.name.to_s).to_sym
        arguments = default_args.merge(args[component_name] || {})
        @components << component.new(arguments)
      end
    end

    def after_initialize; end

    def subscribe(subscriber)
      @subscriptions << subscriber
    end

    def before_component_added(component)
      component
    end

    def after_component_added(component)
      @subscriptions.each { |sub| sub.component_added(self, component) }
      component
    end

    def before_component_removed(component)
      component
    end

    def after_component_removed(component)
      @subscriptions.each { |sub| sub.component_removed(self, component) }
      component
    end

    def serialize
      serialized = { entity_class: self.class.name.to_s, id: id }

      components.each do |component|
        component_name = ECS.underscore(component.name.to_s).to_sym
        serialized[component_name] = component.serialize
      end

      serialized
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    def method_missing(method, *args, &block)
      component = components[method.to_sym]
      return component if component

      super
    end

    def respond_to_missing?(method, _include_private = false)
      !!components[method.to_sym] or super
    end

    class ComponentStore
      include Enumerable
  
      def initialize(parent)
        @component = {}
        @parent = parent
      end
  
      def <<(*components)
        components.flatten.each { |component| add(component) }
  
        self
      end
  
      def [](underscored_component)
        @components[underscored_component]
      end
  
      def add(component)
        unless component.is_a?(ECS::Component)
          message = component.is_a?(Class) ? " You might need to initialize the component before you add it." : ""
          raise ECS::NotAComponentError, "The given value is not a registered component"
        end
  
        altered_component = @parent.before_component_added(component)
        name = ECS.underscore(altered_component.class.name.to_s).to_sym
        @components[name] = altered_component
        @parent.after_component_added(altered_component)
  
        self
      end
  
      def delete(component)
        altered_component = @parent.before_component_removed(component)
        name = ECS.underscore(component.class.name.to_s).to_sym
        @components.delete(name)
        @parent.after_component_remove(component)
  
        self
      end
  
      def empty?
        @components.empty?
      end
  
      def each(&block)
        @components.values.each(&block)
      end
    end
  end

  class Component
    @attribute_options = {}

    def self.inherited(sub)
      super
      sub.instance_variable_set(:@attribute_options, {})
    end

    def self.attribute(name, options = {})
      attr_accessor name

      @attribute_options[name] = options
    end

    class << self
      attr_reader :attribute_options
    end

    def self.Tag(name)
      ECS::Tag(name)
    end

    def initialize(values = {})
      self.class.attribute_options.each do |name, options|
        value = values.fetch(name.to_sym, options[:default])
        instance_variable_set("@#{name}", value)
      end
      after_initialize
    end

    def after_initialize; end

    def serialize
      attrs = { component_class: self.class.name.to_s  }

      instance_variables.each do |attr|
        name = attr.to_s.gsub("@", "").to_sym
        attrs[name] = instance_variable_get(attr)
      end

      attrs
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  # Creates a new empty component at runtime; Returns superclass of ECS::Component.
  def self.Tag(name)
    klass_name = camelize(name)
    
    return Object.const_get(klass_name) if Object.const_defined?(klass_defined)

    klass = Class.new(Component)
    Object.const_set(klass_name, klass)
  end

  class System
    @filter = []

    attr_reader :entities, :world

    # returns the current filter
    def self.filter(*components)
      components.each do |component|
        @filter << component
      end

      @filter
    end

    # resets the filter for each class that inherits from System
    def self.inherited(sub)
      super
      sub.instance_variable_set(:@filter, [])
    end

    def self.Tag(name)
      ECS::Tag(name)
    end

    def initialize(entities: [], world: nil)
      @entities = entities
      @world = world        
      after_initialize
    end

    def after_initialize; end

    # runs the system tick function
    def call(context)
      before_tick(context)
      tick(context)
      after_tick(context)
      self
    end

    def before_tick(context); end

    def tick(context); end

    def after_tick(context); end

    def serialize
      {
        system_class: self.class.name.to_s,
        entities: entities.map(&:serialize),
        world: world ? world.serialize : nil
      }
    end
    
    def inspect
      serialize.to_s
    end
    
    def to_s
      serialize.to_s
    end
  end

  class World
    @default_entities = []
    @default_systems  = []

    def self.inherited(sub)
      super
      sub.instance_variable_set(:@default_entities, [])
      sub.instance_variable_set(:@default_systems, [])
    end

    # adds a default entity to the World
    def self.entity(entity, defaults = {})
      name = defaults[:as]
      @default_entities.push([entity, defaults])

      attr_reader(name.to_sym) if name
    end

    def self.systems(*systems)
      @default_systems += Array(systems).flatten
    end

    class << self
      attr_reader :default_entities, :default_systems
    end

    attr_reader :systems, :entites

    def initialize(entities: [], systems: [])
      default_entities = self.class.default_entities.map do |default|
        klass, attributes = default
        name = attributes[:as]
        entity = klass.new(attributes)
        instance_variable_set("@#{name}", entity) if name

        entity
      end

      @entities = EntityStore.new(self, default_entities + entities)
      @systems  = self.class.default_systems + systems
      after_initialize
    end

    def after_initialize; end

    def before_tick(_context)
      systems.map do |sys|
        entities = filter(sys.filter)

        sys.new(entites: entities, world: self)
      end
    end

    def tick(context)
      results = before_tick(context).map do |sys|
        sys.call(context)
      end

      after_tick(context, results)
    end

    def after_tick(context, results); end

    def component_added(entity, component); end

    def component_removed(entity, component); end

    def filter(*components)
      entities[components.flatten]
    end

    def serialize
      {
        class: self.class.name.to_s,
        entities: @entities.map(&:serialize),
        systems: @systems.map { |system| system.name.to_s }
      }
    end
    
    def inspect
      serialize.to_s
    end
    
    def to_s
      serialize.to_s
    end

    class EntityStore
      include Enumerable

      attr_reader :parent

      def initialize(parent, *entities)
        @parent = parent
        @entity_to_components  = Hash.new { |hash, key| hash[key] = Set.new }
        @component_to_entities = Hash.new { |hash, key| hash[key] = Set.new }
        @entity_ids = {}

        self << entities
      end

      def [](*components_or_ids)
        components_or_ids
          .flatten
          .map { |component_or_id| select_entities(component_or_id) }
          .reduce { |acc, i| i & acc }
      end

      # Gets entities by component or id.
      def select_entities(component_or_id)
        if component_or_id.is_a?(Numeric)
          Array(@entity_ids[component_or_id])
        else
          @component_to_entities[component_or_id]
        end
      end

      # Adds Entities to the EntityStore
      def <<(entities)
        Array(entities).flatten.each { |e| add(e) }
        self
      end

      # Adds an Entity to the EntityStore.
      def add(entity)
        entity.subscribe(self)

        @entity_ids[entity.id] = entity
        components = entity.components.map(&:class)
        @entity_to_components[entity].merge(components)

        components.each { |component| @component_to_entities[component].add(entity) }
        entity.components.each { |component| @parent.component_added(entity, component) }

        self
      end

      # Removes an Entity from the EntityStore.
      def delete(entity)
        @entity_ids.delete(entity.id)
        components = Array(@entity_to_components.delete(entity))

        components.each do |component|
          @component_to_entities[component].delete(entity)
        end
      end

      # Returns true if the EntityStore has no Entities.
      def empty?
        @entity_to_components.empty?
      end

      # Returns an Enumerator for all of the Entities.
      def each(&block)
        @entity_to_components.keys.each(&block)
      end

      # Updates the EntityStore when an Entity's Components are added.
      def component_added(entity, component)
        @component_to_entities[component.class].add(entity)
        @parent.component_added(entity, component)
      end

      # Updates the EntityStore when an Entity's Components are removed.
      def component_removed(entity, component)
        @component_to_entities[component.class].delete(entity)
        @parent.component_removed(entity, component)
      end
    end
  end

  # Internal: An implementation of Set.
  class Set
    include Enumerable

    # Internal: Initializes a new Set.
    #
    # entries - The initial Array list of entries for the Set
    def initialize(entries = [])
      @hash = {}
      merge(entries)
    end

    # Internal: Adds a new entry to the Set.
    #
    # entry - The object to add to the Set.
    #
    # Returns the Set.
    def add(entry)
      @hash[entry] = true
      self
    end

    # Internal: Adds a new entry to the Set.
    #
    # entry - The object to add to the Set.
    #
    # Returns the Set.
    def delete(entry)
      @hash.delete(entry)
      self
    end

    # Internal: Adds multiple objects to the Set.
    #
    # entry - The Array list of objects to add to the Set.
    #
    # Returns the Set.
    def merge(entries)
      Array(entries).each { |entry| add(entry) }
      self
    end

    # Internal: alias of merge
    def +(other)
      merge(other)
    end

    # Internal: Returns an Enumerator for all of the entries in the Set.
    def each(&block)
      @hash.keys.each(&block)
    end

    # Internal: Returns true if the object is in the Set.
    #
    # member - The object to search the Set for.
    #
    # Returns a boolean.
    def member?(member)
      @hash.key?(member)
    end

    # Internal: Returns true if there are no entries in the Set.
    #
    # Returns a boolean.
    def empty?
      @hash.empty?
    end

    # Internal: Returns the intersection of two Sets.
    #
    # other - The Set to intersect with
    #
    # Returns a new Set of all of the common entries.
    def &(other)
      response = Set.new
      each do |key, _|
        response.add(key) if other.member?(key)
      end

      response
    end

    def ==(other)
      hash == other.hash
    end

    # Internal: Returns a unique hash value of the Set.
    def hash
      @hash.hash
    end

    # Internal: Returns an Array representation of the Set.
    def to_a
      @hash.keys
    end

    # Internal: Serializes the Set.
    def serialize
      to_a.inspect
    end

    # Internal: Inspects the Set.
    def inspect
      to_a.inspect
    end

    # Internal: Returns a String representation of the Set.
    def to_s
      to_a.to_s
    end
  end
  
  def self.underscore(string)
    string.to_s.split("::").last.bytes.map.with_index do |byte, i|
      if byte > 64 && byte < 97
        downcased = byte + 32
        i.zero? ? downcased.chr : "_#{downcased.chr}"
      else
        byte.char
      end
    end.join
  end

  def self.camelize(string)
    modifier = -32

    string.to_s.bytes.map do |byte|
      if byte == 95
        modifier = -32
        nil
      else
        char = (byte + modifier).chr
        modifier = 0
        char
      end
    end.compact.join
  end
end

