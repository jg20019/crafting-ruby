require_relative "./token_type"
require_relative "./token"
require_relative "./expr"
require_relative "./runtime_error"
require_relative "./environment"
require_relative "./lox_function"

class Interpreter
  include ExprVisitor
  include StmtVisitor 

  attr_reader :globals

  def initialize(lox)
    @lox = lox
    @globals = Environment.new
    @environment = @globals

    @globals.define("clock", Class.new do 
      def arity
        0
      end

      def call(interpreter, arguments)
        Time.now.strftime('%s%L').to_i / 1000.0
      end

      def to_s
        "<native fn>" 
      end
    end)
  end

  def interpret(statements)
    begin
      statements.each do |stmt|
        execute(stmt)
      end
    rescue LoxRuntimeError => e
      @lox.runtimeError(e)
    end
  end

  def evaluate(expr)
    expr.accept(self)
  end

  def execute(stmt)
    stmt.accept(self)
  end

  def executeBlock(statements, environment)
    previous = @environment
    begin
      @environment = environment
      statements.each do |statement|
        execute(statement)
      end
    ensure
      @environment = previous
    end
  end

  def visitBlockStmt(stmt)
    executeBlock(stmt.statements, Environment.new(@environment))
    return nil
  end

  def visitExpressionStmt(stmt)
    evaluate(stmt.expression)
  end

  def visitFunctionStmt(stmt)
    function = LoxFunction.new(stmt)
    @environment.define(stmt.name.lexeme, function)
  end

  def visitIfStmt(stmt)
    if (truthy?(evaluate(stmt.condition)))
      execute(stmt.thenBranch)
    elsif (stmt.elseBranch)
      execute(stmt.elseBranch)
    end
  end

  def visitPrintStmt(stmt) 
    value = evaluate(stmt.expression)
    puts(value.to_s)
  end

  def visitVarStmt(stmt)
    value = nil
    if (stmt.initializer) 
      value = evaluate(stmt.initializer)
    end

    @environment.define(stmt.name.lexeme, value)
  end

  def visitWhileStmt(stmt)
    while (truthy?(evaluate(stmt.condition))) 
      execute(stmt.body)
    end
  end

  def visitAssignExpr(expr)
    value = evaluate(expr.value)
    @environment.assign(expr.name, value)
    value
  end

  def visitBinaryExpr(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)
    case expr.operator.type
    when TokenType::MINUS
      checkNumberOperands(expr.operator, left, right)
      return left - right
    when TokenType::SLASH
      checkNumberOperands(expr.operator, left, right)
      if right == 0
        raise LoxRuntimeError.new(expr.operator, "Can't divide by zero")
      end
      return left / right
    when TokenType::STAR 
      checkNumberOperands(expr.operator, left, right)
      return left * right
    when TokenType::PLUS
      if left.is_a?(Numeric) && right.is_a?(Numeric)
        return left + right
      end
      if left.is_a?(String) && right.is_a?(String)
        return left + right
      end
      raise LoxRuntimeError.new(expr.operator, 
        "Operands must be two numbers or two strings.")
    when TokenType::GREATER
      checkNumberOperands(expr.operator, left, right)
      return left > right 
    when TokenType::GREATER_EQUAL
      checkNumberOperands(expr.operator, left, right)
      return left >= right
    when TokenType::LESS
      checkNumberOperands(expr.operator, left, right)
      return left < right
    when TokenType::LESS_EQUAL
      checkNumberOperands(expr.operator, left, right)
      return left <= right
    when TokenType::BANG_EQUAL
      return !equal?(left, right)
    when TokenType::EQUAL_EQUAL
      return equal?(left, right)
    end
    # Unreachable.
  end

  def visitCallExpr(expr)
    callee = evaluate(expr.callee)

    if (!callee.respond_to?(:call))
      raise LoxRuntimeError.new(expr.paren,
        "Can only call functions and classes.")
    end

    arguments = []
    expr.arguments.each do |argument|
      arguments << evaluate(argument)
    end

    function = callee
    if (arguments.length != function.arity)
      raise LoxRuntimeError.new(expr.paren, 
          "Expected #{function.arity} arguments but got #{arguments.length}.")
    end
    function.call(self, arguments)
  end

  def visitLiteralExpr(expr)
    expr.value
  end

  def visitLogicalExpr(expr)
    left = evaluate(expr.left)
    if (expr.operator.type == TokenType::OR)
      return left if (truthy?(left))
    else 
      return left unless (truthy?(left))
    end
    evaluate(expr.right)
  end

  def visitGroupingExpr(expr)
    evaluate(expr.expression)
  end

  def visitUnaryExpr(expr)
    right = evaluate(expr.right)

    case expr.operator.type
    when TokenType::MINUS
      checkNumberOperand(expr.operator, right)
      return -right.to_f
    when TokenType::BANG
      return !truthy?(right)
    end

    # Unreachable
    return nil
  end

  def visitVariableExpr(expr)
    @environment.get(expr.name)
  end

  def checkNumberOperand(operator, operand)
    return if operand.is_a? Numeric
    raise LoxRuntimeError.new(operator, "Operand must be a number")
  end

  def checkNumberOperands(operator, left, right)
    return if left.is_a?(Numeric) && right.is_a?(Numeric)
    raise LoxRuntimeError.new(operator, "Operands must be numbers")
  end

  def truthy?(value)
    # Lox follows Ruby rules and we are using so...
    value
  end

  def equal?(a, b)
    return true if a == nil && b == nil
    return false if a == nil

    return a == b
  end
end
