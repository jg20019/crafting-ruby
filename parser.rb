require_relative './token_type'
require_relative './expr'

class ParseError < StandardError
end

class Parser
  attr_accessor :tokens, :current
  
  def initialize(tokens, lox)
    @tokens = tokens
    @current = 0
    @lox = lox
  end

  def parse
    begin
      expression
    rescue ParseError
      nil
    end
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

  def unary
    if (match(TokenType::BANG, TokenType::MINUS))
      operator = previous
      right = unary
      return Unary.new(operator, right)
    end
    return primary
  end
  
  def primary
    return Literal.new(false) if (match(TokenType::FALSE)) 
    return Literal.new(true)  if (match(TokenType::TRUE)) 
    return Literal.new(nil)   if (match(TokenType::NIL)) 

    if (match(TokenType::NUMBER, TokenType::STRING)) 
      return Literal.new(previous.literal)
    end

    if (match(TokenType::LEFT_PAREN)) 
      expr = expression
      consume(TokenType::RIGHT_PAREN, "Expect ')' after expression.")
      return Grouping.new(expr)
    end

    raise error(peek, "Expect expression.")
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
    return false if at_end?
    peek.type == type
  end

  def match(*types)
    if types.any? {|type| check?(type)}
      advance
      return true
    end
    return false
  end

  def consume(type, message) 
    return advance if (check?(type))
    raise error(peek, message)
  end

  def error(token, message)
    @lox.parseError(token, message)
    return ParseError.new
  end

  def synchronize
    advance
    while (!at_end?)
      return if previous.type == TokenType::SEMICOLON

      case peek.type
      when TokenType::CLASS 
          return
      when TokenType::FUN 
          return
      when TokenType::VAR 
          return
      when TokenType::FOR 
          return
      when TokenType::IF 
          return
      when TokenType::WHILE 
          return
      when TokenType::PRINT 
          return
      when TokenType::RETURN 
          return
      end
      advance
    end
  end
end
