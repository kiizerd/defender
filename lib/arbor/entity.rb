module Arbor
  class Entity < Node
    def initialize opts
      super(opts)
    
      opts.each do |key, value|
        key_symbol = "@#{key}".to_sym
        instance_variable_set(key_symbol, value)
      end
    end

    def serialize
      properties = relevant_variables.map do |key|
        [key, self.instance_variable_get(key)]
      end.to_h
      super.merge(**properties)
    end

    def relevant_variables
      instance_variables - [:@parent, :@children, :@name]
    end
  end
end