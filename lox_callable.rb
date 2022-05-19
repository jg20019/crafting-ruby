
class LoxCallable
  def initialize(arity, procedure, str)
    @arity = arity
    @proc = procedure
    @str = str
  end

  def arity
    @arity
  end

  def call(interpreter, arguments)
    @proc.call(interpreter, arguments)
  end

  def to_s
    @str
  end
end
