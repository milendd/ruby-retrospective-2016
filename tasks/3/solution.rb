def help_option_format(option)
  parameter_text = (option[:parameter].nil? ? '' : '=' + option[:parameter])
  "#{' ' * 4}-#{option[:short_name]}, --#{option[:long_name]}" \
  "#{parameter_text} #{option[:description]}"    
end

def help_format(command_name, arguments, options)
  result = []
  arguments_text = arguments.map { |x| '[' + x[:name] + ']' }.join(' ')
  result << "Usage: #{command_name} #{arguments_text}"
  options.each { |option| result << help_option_format(option) }
  result.join("\n")
end

def create_option(short_name, long_name, description, parameter, block)
  option = {
    short_name: short_name,
    long_name: long_name,
    description: description,
    parameter: parameter,
    block: block
  }
  option
end

class CommandParser
  def initialize(command_name)
    @command_name = command_name
    @arguments = []
    @options = []
  end
  
  def argument(name, &block)
    argument = { name: name, block: block }
    @arguments << argument
  end
  
  def option(short_name, long_name, description, parameter = nil, &block)
    option = create_option(short_name, long_name, description, parameter, block)
    @options << option
  end
  
  def option_with_parameter(s_name, long_name, description, parameter, &block)
    option(s_name, long_name, description, parameter, &block)
  end
  
  def help
    help_format(@command_name, @arguments, @options)
  end
  
  def block_call(runner, option, index, name, search_name, parameter)
    if option[name] == search_name
      @options[index][:block].call(runner, parameter)
      1
    else
      0
    end
  end
  
  def block_call_long_name(runner, argument, option_index)
    if @options[option_index][:long_name] == argument[2..-1]
      @options[option_index][:block].call(runner, true)
      1
    else
      parts = argument[2..-1].split('=')
      option = @options[option_index]
      block_call(runner, option, option_index, :long_name, parts[0], parts[1])
    end
  end
  
  def block_call_short_name(runner, argument, option_index)
    if @options[option_index][:short_name] == argument[1..-1]
      @options[option_index][:block].call(runner, true)
      1
    else
      name = argument[1]
      parameter = argument[2..-1]
      option = @options[option_index]
      block_call(runner, option, option_index, :short_name, name, parameter)
    end
  end
  
  def parse(runner, argv, argument_index = 0, option_index = 0)
    argv.each do |argument|
      if argument.start_with? '--'
        option_index += block_call_long_name(runner, argument, option_index)
      elsif argument.start_with? '-'
        option_index += block_call_short_name(runner, argument, option_index)
      else
        @arguments[argument_index][:block].call(runner, argument)
        argument_index += 1
      end
    end
  end
end
