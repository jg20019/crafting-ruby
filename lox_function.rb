
class LoxFunction 
  attr_reader :declaration

  def initialize(declaration)
    @declaration = declaration
  end

  def call(interpreter, arguments)
    environment = Environment.new(interpreter.globals)
    (0..@declaration.params.length - 1).each do |i|
      environment.define(@declaration.params[i].lexeme, arguments[i])
    end

    interpreter.executeBlock(@declaration.body, environment)
  end

  def arity
    @declaration.params.length
  end

  def to_s
    "<fn #{@declaration.name.lexeme}>"
  end
end
