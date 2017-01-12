def get_next_element(element, index)
  key = (element.is_a?Array) ? index.to_i : index.to_sym
  
  current = element[key]
  current = element[key.to_s] if current.nil? && (!key.is_a?Integer)
  current
end

class Hash
  @next_deep_element
  
  def fetch_deep_recursive(current_element, components)
    if (current_element.is_a? Hash) || (current_element.is_a? Array)
      @next_deep_element = current_element
      fetch_deep components[1..-1].join('.')
    else
      @next_deep_element = nil
      current_element
    end
  end
  
  def fetch_deep(path)
    components = path.split('.')
    @next_deep_element ||= self
    current = get_next_element(@next_deep_element, components.first)
    fetch_deep_recursive(current, components)
  end
  
  def reshape_recursive(shape, key)
    if shape[key].is_a? String
      fetch_deep(shape[key])
    else
      reshape(shape[key])
    end
  end
  
  def reshape(shape)
    shape.each_key do |key|
      shape[key] = reshape_recursive(shape, key)
    end
    shape
  end
end

class Array
  def reshape(shape)
    each.map { |x| x.reshape(shape.dup) }
  end
end
