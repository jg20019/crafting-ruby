require_relative 'runtime_error'

class Environment
  attr_accessor :values
  attr_reader :enclosing

  def initialize(enclosing=nil)
    @enclosing = enclosing
    @values = Hash.new
  end

  def define(name, value)
    @values[name] = value
  end

  def get(name)
    if (@values.include?(name.lexeme)) 
      return @values[name.lexeme]
    end

    return @enclosing.get(name) if (@enclosing)

    raise LoxRuntimeError.new(name,
      "Undefined variable  '#{name.lexeme}'.")
  end

  def assign(name, value)
    if (@values.include?(name.lexeme))
      @values[name.lexeme] = value
      return
    end

    return @enclosing.assign(name, value) if @enclosing

    throw LoxRuntimeError.new(name,
      "Undefined variable '#{name.lexeme}'.")
  end
end
