#!/home/jgibson/.asdf/shims/ruby

require_relative 'token_type'
require_relative 'scanner'
require_relative 'parser'
require_relative 'interpreter'  

class Lox
  @@hadError = false
  @@hadRuntimeError = false
  @@interpreter = Interpreter.new(self)

  def Lox.main
    if ARGV.length > 1 
      puts "Usage: rlox [script]"
      exit 64
    elsif ARGV.length == 1
      self.runFile(ARGV[0])
    else
      self.runPrompt
    end
  end

  def Lox.run(source)
    scanner = Scanner.new(source, self)
    tokens = scanner.scanTokens
    parser = Parser.new(tokens, self)
    expression = parser.parse
    
    return if @@hadError
    @@interpreter.interpret(expression)
  end

  def Lox.runFile(path)
    file = File.new(path, "r")
    content = file.read()
    self.run(content)
    exit(65) if @@hadError
    exit(70) if @@hadRuntimeError
  end

  def Lox.runPrompt
    loop do 
      print "> "
      line = gets
      break unless line
      self.run(line)
      @@hadError = false
    end
  end

  def Lox.error(line, message)
    self.report(line, "", message)
  end

  def Lox.report(line, where, message)
    puts "[line #{line}] Error #{where}: #{message}"
    @@hadError = true
  end

  def Lox.parseError(token, message)
    if (token.type == TokenType::EOF)
      report(token.line, " at end", message)
    else
      report(token.line, " at '#{token.lexeme}'", message)
    end
  end

  def Lox.runtimeError(error) 
    STDERR.puts("#{error.message} \n[line #{error.token.line}]")
    @@hadRuntimeError = true
  end
end

Lox.main
