  class Set
    include Enumerable
    def initialize(entries = [])
      @hash = {}
      merge(entries)
    end
    
    def add(entry)
      @hash[entry] = true
      self
    end
    
    def delete(entry)
      @hash.delete(entry)
      self
    end
    
    def merge(entries)
      Array(entries).each { |entry| add(entry) }
      self
    end
    
    def +(other)
      merge(other)
    end
    
    def each(&block)
      @hash.keys.each(&block)
    end
    
    def member?(member)
      @hash.key?(member)
    end
    
    def empty?
      @hash.empty?
    end
    
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
    
    def hash
      @hash.hash
    end
    
    def to_a
      @hash.keys
    end
    
    def serialize
      to_a.inspect
    end
    
    def inspect
      to_a.inspect
    end
    
    def to_s
      to_a.to_s
    end
  end