require_relative "token_type" 
require_relative "token"

class Scanner
  attr_reader :source, :tokens, :start, :current, :line, :lox

  @@keywords = {
    "and"    => TokenType::AND,
    "class"  => TokenType::CLASS,
    "else"   => TokenType::ELSE,
    "false"  => TokenType::FALSE,
    "for"    => TokenType::FOR,
    "fun"    => TokenType::FUN,
    "if"     => TokenType::IF,
    "nil"    => TokenType::NIL,
    "or"     => TokenType::OR,
    "print"  => TokenType::PRINT,
    "return" => TokenType::RETURN,
    "super"  => TokenType::SUPER,
    "this"   => TokenType::THIS,
    "true"   => TokenType::TRUE,
    "var"    => TokenType::VAR,
    "while"  => TokenType::WHILE
  }

  def initialize(source, lox)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
    @lox = lox
  end


  def scanTokens
    until at_end?
      @start = @current
      scanToken
    end
    tokens << Token.new(TokenType::EOF, "", nil, @line)
  end

  def scanToken
    ch = advance
    case ch
    when "("
      addToken(TokenType::LEFT_PAREN)
    when ")"
      addToken(TokenType::RIGHT_PAREN)
    when "{"
      addToken(TokenType::LEFT_BRACE)
    when "}"
      addToken(TokenType::RIGHT_BRACE)
    when ","
      addToken(TokenType::COMMA)
    when "."
      addToken(TokenType::DOT)
    when "-"
      addToken(TokenType::MINUS)
    when "+"
      addToken(TokenType::PLUS)
    when ";"
      addToken(TokenType::SEMICOLON)
    when "*"
      addToken(TokenType::STAR)
    when "!"
      addToken(match?("=") ? TokenType::BANG_EQUAL : TokenType::BANG)
    when "="
      addToken(match?("=") ? TokenType::EQUAL_EQUAL : TokenType::EQUAL)
    when "<"
      addToken(match?("=") ? TokenType::LESS_EQUAL : TokenType::LESS)
    when ">"
      addToken(match?("=") ? TokenType::GREATER_EQUAL : TokenType::GREATER)
    when "/"
      if match?("/")
        advance while (peek != '\n' && !at_end?)
      else
        addToken(TokenType::SLASH)
      end
    when '"'
      string
    when /\d/
      number
    when /[_a-zA-Z]/
      identifier
    when "\n"
      @line += 1
    when /\s/
      nil
    else
      @lox.error(@line, "Unexpected character: '#{ch}'")
    end
  end

  def alpha?(ch)
    !!ch.match(/[_a-zA-Z]/)
  end

  def alpha_numeric?(ch)
    alpha?(ch) || digit?(ch)
  end

  def digit?(ch)
    !!ch.match(/\d/)
  end

  def identifier
    while alpha_numeric?(peek)
      advance
    end

    text = @source[@start..@current-1]
    token_type = @@keywords.fetch(text, TokenType::IDENTIFIER)
    if token_type == TokenType::IDENTIFIER 
      addToken(token_type, text)
    else
      addToken(token_type)
    end
  end

  def number
    advance while digit?(peek)

    if peek == '.' && digit?(peek_next) 
      # Consume the .
      advance
      advance while digit?(peek)
    end

    addToken(TokenType::NUMBER, 
             @source[@start..@current-1].to_f)    
  end

  def string
    until peek == '"' || at_end?
      @line += 1 if peek == '\n'
      advance
    end

    if at_end? 
      @lox.error(line, "Unterminate string")
      return
    end

    # The closing "
    advance
  
    # Trim the surrounding quotes.
    value = @source[@start + 1..@current - 2]
    addToken(TokenType::STRING, value)
  end
  
  def peek()
    return '\0' if at_end? 
    @source[@current]
  end

  def peek_next()
    index = @current + 1
    return '\0' if index > @source.length
    @source[index]
  end

  def match?(expected)
    return false if at_end? || @source[@current] != expected 
    @current += 1
    true
  end

  def advance
    ch = source[@current]
    @current += 1
    ch
  end

  def addToken(type, literal=nil)
    text = @source[@start..@current-1]
    tokens << Token.new(type, text, literal, line)
  end

  def at_end?
    @current >= @source.length
  end
end
