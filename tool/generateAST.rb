
def defineAST(output_dir, base_name, types)
  writer = File.new("#{output_dir}/#{base_name}.rb", "w")

  base_name = base_name.capitalize
  defineVisitor(writer, base_name, types)

  types.each do |type|
    class_name = type.split(":")[0].strip
    fields = type.split(":")[1].strip
    defineType(writer, base_name, class_name, fields)
  end

  writer.close()
end

def defineType(writer, base_name, class_name, fields)
  field_list = fields.split
  accessors = field_list.collect { |f| ":#{f}" }.join(", ")
  arguments = field_list.join(", ")
  
  writer.puts("class #{class_name}")
  writer.puts("    attr_accessor #{accessors}")
  writer.puts("    def initialize(#{arguments})")
  field_list.each do |field| 
    writer.puts("        @#{field} = #{field}")  
  end
  writer.puts("    end")
  writer.puts
  writer.puts("    def accept(visitor)")
  writer.puts("        visitor.visit#{class_name}#{base_name}(self)")
  writer.puts("    end")
  writer.puts("end")
  writer.puts
end

def defineVisitor(writer, base_name, types)
  writer.puts("module #{base_name}Visitor")
  types.each do |type| 
    type_name = type.split(':')[0].strip
    writer.puts("    def  visit#{type_name}#{base_name} (#{base_name.downcase})")
    writer.puts("        raise NotImplementedError")
    writer.puts("    end")
  end
  writer.puts("end")
  writer.puts
end

if ARGV.length != 1
  puts "Usage: generate_ast <output directory>"
  exit(64)
end

outputDir = ARGV[0]
defineAST(outputDir, "expr", [
  "Assign   : name value",
  "Binary   : left operator right",
  "Call     : callee paren arguments",
  "Grouping : expression",
  "Literal  : value",
  "Logical  : left operator right",
  "Unary    : operator right",
  "Variable : name",
])

defineAST(outputDir, "stmt", [
  "Block      : statements",
  "Expression : expression",
  "If         : condition thenBranch elseBranch",
  "Print      : expression",
  "Var        : name initializer",
  "While      : condition body"
])
