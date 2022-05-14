require_relative 'runtime_error'

class Environment
  attr_accessor :values

  def initialize()
    @values = Hash.new
  end

  def define(name, value)
    @values[name] = value
  end

  def get(name)
    if (@values.include?(name.lexeme)) 
      return @values[name.lexeme]
    end

    raise LoxRuntimeError.new(name,
      "Undefined variable  '#{name.lexeme}'.")
  end

  def assign(name, value)
    if (@values.include?(name.lexeme))
      @values[name.lexeme] = value
      return
    end

    throw LoxRuntimeError.new(name,
      "Undefined variable '#{name.lexeme}'.")
  end
end
