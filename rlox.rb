#!/home/jgibson/.asdf/shims/ruby

require_relative 'scanner.rb'

class Lox
  @@hadError = false
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
    tokens.each do |token| 
      puts token
    end
  end

  def Lox.runFile(path)
    file = File.new(path, "r")
    content = file.read()
    self.run(content)
    exit(65) if @@hadError
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
end

Lox.main
