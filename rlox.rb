#!/home/jgibson/.asdf/shims/ruby

class Lox
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

  def Lox.run(input)
  end

  def Lox.runFile(path)
    file = File.new(path, "r")
    content = file.read()
    self.run(content)
  end

  def Lox.runPrompt
    loop do 
      print "> "
      line = gets
      break unless line
      self.run(line)
    end
  end
end

Lox.main
