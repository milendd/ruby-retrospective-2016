class Helper
  def self.hash_constains_in_hash(hash, searched)
    eql = !hash[:id].nil? && !searched[:id].nil? && hash[:id] == searched[:id]
    return true if eql
    
    contains = true
    searched.each do |key, value|
      contains = false if hash[key] != value
    end
    contains
  end
  
  def self.hash_to_obj(obj, hash)
    hash.each do |key, value|
      setter_name = key.to_s + '='
      obj.send(setter_name, value)
    end
    obj
  end
end
class Store
  attr_reader :incrementator
  
  def initialize
    @incrementator = 1
  end
  
  private
  
  def insert_id_if_none(hash)
    if hash[:id].nil?
      hash[:id] = @incrementator
      @incrementator += 1
    end
  end
end
class ArrayStore < Store
  attr_reader :storage
  
  def initialize
    super
    @storage = []
  end
  
  def create(hash)
    insert_id_if_none(hash)
    @storage << hash
  end
  
  def find(search_option)
    result = []
    @storage.each do |current|
      result << current if Helper.hash_constains_in_hash(current, search_option)
    end
    result
  end
  
  def update(id, hash)
    element = find(id: id).first
    hash.each do |key, value|
      element[key] = value
    end
  end
  
  def delete(search_option)
    elements = find(search_option)
    @storage -= elements
  end
end
class HashStore < Store
  attr_reader :storage
  
  def initialize
    super
    @storage = {}
  end
  
  def create(hash)
    insert_id_if_none(hash)
    @storage[hash[:id]] = hash
  end
  
  def find(search_option)
    result = []
    @storage.each do |_, current|
      result << current if Helper.hash_constains_in_hash(current, search_option)
    end
    result
  end
  
  def update(id, hash)
    element = find(id: id).first
    hash.each do |key, value|
      element[key] = value
    end
  end
  
  def delete(search_option)
    elements = find(search_option)
    @storage = @storage.delete_if { |_, value| elements.include? value }
  end
end
class DataModel
  attr_accessor :id
  
  def initialize(data = nil)
    unless data.nil?
      data.each do |method_name, value|
        setter_name = method_name.to_s + '='
        public_send(setter_name, value) if respond_to? setter_name
        # because id is private, no one should be modifying it
        send(setter_name, value) if setter_name == 'id='
      end
    end
  end
  
  def save
    hash = self_to_h
    if self.class.store.find(hash) == []
      self.class.store.create(hash)
    else
      self.class.store.update(hash[:id], hash)
    end
    @id = hash[:id]
    self
  end
  
  def delete
    element = self.class.store.find(self_to_h).first
    raise DeleteUnsavedRecordError.new if element.nil?
    self.class.store.delete(element)
  end
  
  def ==(other)
    return true if self.id == other.id && !self.id.nil?
    return true if self.object_id == other.object_id
    self.equal? other
  end
  
  private
  
  def self_to_h
    result = {}
    self.class.attributes_data.each { |method| result[method] = public_send(method) }
    result[:id] = @id unless @id.nil?
    result
  end
end
DataModel::DeleteUnsavedRecordError = Class.new(StandardError) do
  attr_reader :object
  def initialize(object = nil)
    @object = object
  end
end
DataModel::UnknownAttributeError = Class.new(StandardError) do
  attr_reader :object
  def initialize(object = nil)
    @object = object
  end
end
class << DataModel
  attr_accessor :attributes_data
  attr_accessor :store
  
  def attributes(*attr)
    return @attributes_data if attr == []
    @attributes_data = [:id]
    attr.each do |attribute| 
      attr_accessor(attribute)
      define_singleton_method "find_by_#{attribute}" do |item|
        where(attribute => item)
      end
      @attributes_data << attribute
    end
    define_singleton_method('find_by_id') { |item| @store.find(id: item) }
  end
  
  def data_store(store = nil)
    return @store if store.nil?
    @store = store
  end
  
  def where(search_option)
    result = []
    missing = (search_option.keys - @attributes_data).first
    unless missing.nil?
      raise DataModel::UnknownAttributeError.new, "Unknown attribute #{missing}"
    end
    @store.find(search_option).each do |element|
      result << Helper.hash_to_obj(self.new, element)
    end
    result
  end
end
