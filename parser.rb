require_relative 'token_type'
require_relative 'expr'
require_relative 'stmt'


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
    statements = []
    while (!at_end?) 
      statements << declaration
    end
    statements
  end

  def declaration
    begin
      return function("function") if (match(TokenType::FUN))
      return varDeclaration if (match(TokenType::VAR))
      return statement
    rescue ParseError
      synchronize
      return nil
    end
  end

  def statement
    return forStatement     if (match(TokenType::FOR))
    return ifStatement      if (match(TokenType::IF)) 
    return printStatement   if (match(TokenType::PRINT)) 
    return whileStatement   if (match(TokenType::WHILE))
    return Block.new(block) if (match(TokenType::LEFT_BRACE))
    return expressionStatement
  end

  def forStatement
    consume(TokenType::LEFT_PAREN, "Expect '(' after 'for'.")

    initialize = nil
    if (match(TokenType::SEMICOLON)) 
        initializer = nil
    elsif (match(TokenType::VAR)) 
        initializer = varDeclaration
    else 
        initializer = expressionStatement
    end

    condition = nil
    if (!check?(TokenType::SEMICOLON)) 
      condition = expression
    end
    consume(TokenType::SEMICOLON, "Expect ';' after loop condition.")

    increment = nil
    if (!check?(TokenType::RIGHT_PAREN))
      increment = expression
    end
    consume(TokenType::RIGHT_PAREN, "Expect ')' after for clauses.")

    body = statement

    if (increment)
      body = Block.new([body, Expression.new(increment)])
    end

    if (condition == nil) 
      condition = Literal.new(true)
    end

    body = While.new(condition, body)

    if (initializer)
      body = Block.new([initializer, body])
    end

    return body
  end

  def ifStatement 
    consume(TokenType::LEFT_PAREN, "Expect '(' after 'if'.")
    condition = expression
    consume(TokenType::RIGHT_BRACE, "Expect ')' after 'if'.")

    thenBranch = statement
    elseBranch = nil
    if (match(TokenType::ELSE))
      elseBranch = statement
    end

    return If.new(condition, thenBranch, elseBranch)
  end
  
  def printStatement
    value = expression
    consume(TokenType::SEMICOLON, "Expect ';' after value.")
    Print.new(value)
  end

  def whileStatement
    consume(TokenType::LEFT_PAREN, "Expect '(' after 'while'.")
    condition = expression
    consume(TokenType::RIGHT_PAREN, "Expect ')' after 'condition'.")
    body = statement
    return While.new(condition, body)
  end

  def varDeclaration
    name = consume(TokenType::IDENTIFIER, "Expect variable name.")

    initializer = nil
    if (match(TokenType::EQUAL)) 
      initializer = expression
    end

    consume(TokenType::SEMICOLON, "Expect ';' after variable declartion.")
    Var.new(name, initializer)
  end

  def expressionStatement
    expr = expression
    consume(TokenType::SEMICOLON, "Expect ';' after expression.")
    Expression.new(expr)
  end

  def function(kind) 
    name = consume(TokenType::IDENTIFIER, "Expect #{kind} name.")
    consume(TokenType::LEFT_PAREN, "Expect '(' after #{kind} name.") 
    parameters = []
    if (!check?(TokenType::RIGHT_PAREN))
      if (parameters.length) >= 255)
        error(peek, "Cant' have more than 255 parameters")
      end
      parameters << consume(TokenType::IDENTIFIER, "Expect parameter name.")

      while (match(TokenType::COMMA))
        if (parameters.length) >= 255)
          error(peek, "Cant' have more than 255 parameters")
        end
        parameters << consume(TokenType::IDENTIFIER, "Expect parameter name.")
      end
    end

    consume(TokenType::RIGHT_PAREN, "Expect ')' after parameters.")

    consume(TokenType::LEFT_BRACE, "Expect '{' before #{kind} body.")
    body = block
    return Function.new(name, parameters, body)
  end

  def block
    statements = []
    while (!check?(TokenType::RIGHT_BRACE) && !at_end?)
      statements << declaration 
    end

    consume(TokenType::RIGHT_BRACE, "Expect '}' after block.")
    statements
  end

  def assignment
    expr = orExpr

    if (match(TokenType::EQUAL))
      equals = previous
      value = assignment

      if (expr.is_a?(Variable))
        name = expr.name
        return Assign.new(name, value)
      end

      return error(equals, "Invalid assignment target.")
    end
    expr
  end

  def orExpr 
    expr = andExpr

    while (match(TokenType::OR))
      operator = previous
      right = andExpr()
      expr = Logical.new(expr, operator, right)
    end

    expr
  end

  def andExpr
    expr = equality

    while (match(TokenType::AND))
      operator = previous
      right = equality
      expr = Logical.new(expr, operator, right)
    end

    expr
  end

  def expression
    assignment
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
    return call
  end

  def finishCall(callee)
    arguments = []
    if (!check?(TokenType::RIGHT_PAREN))
      arguments << expression
      while (match(TokenType::COMMA))
        if (arguments.length >= 255)
          error(peek, "Can't have more than 255 arguments.")
        end
        arguments << expression
      end
    end

    paren = consume(TokenType::RIGHT_PAREN,
                    "Expect ')' after arguments.")

    Call.new(callee, paren, arguments)
  end

  def call
    expr = primary
    while (true) 
      if (match(TokenType::LEFT_PAREN))
        expr = finishCall(expr)
      else
        break
      end
    end

    expr
  end
  
  def primary
    return Literal.new(false) if (match(TokenType::FALSE)) 
    return Literal.new(true)  if (match(TokenType::TRUE)) 
    return Literal.new(nil)   if (match(TokenType::NIL)) 

    if (match(TokenType::NUMBER, TokenType::STRING)) 
      return Literal.new(previous.literal)
    end

    if (match(TokenType::IDENTIFIER))
      return Variable.new(previous)
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
