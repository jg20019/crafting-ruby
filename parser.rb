require_relative './token_type'
require_relative './expr'

class Parser
  attr_accessor :tokens, :current
  
  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def expression
    equality
  end

  def equality
    expr = comparison
    while (match(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)) 
      operator = previous
      right = comparison
      expr = Binary.new(expr, operator, right)
    end
    expr
  end

  def comparison
    expr = term
    while (match(TokenType::LESS, TokenType::LESS_EQUAL, TokenType::GREATER, TokenType::GREATER_EQUAL))
      operator = previous
      right = term
      expr = Binary.new(expr, operator, right)
    end
    expr
  end

  def term
    expr = factor
    while (match(TokenType::MINUS, TokenType::PLUS))
      operator = previous
      right = factor
      expr = Binary.new(expr, operator, right)
    end
    expr
  end

  def factor
    expr = unary
    while (match(TokenType::SLASH, TokenType::STAR)) 
      operator = previous
      right = unary
      expr = Binary.new(expr, operator, right)
    end
    expr
  end

  def at_end?
    peek.type == TokenType::EOF
  end

  def peek
    @tokens[@current]
  end

  def previous
    @tokens[@current - 1]
  end

  def advance
    @current += 1 unless at_end?
    previous
  end


  def check?(type) 
    return false at_end?
    peek.type == type
  end

  def match(*types)
    if types.any? {|type| check?(type)}
      advance
      true
    end
    false
  end


end
