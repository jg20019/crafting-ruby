
def defineAST(output_dir, base_name, types)
  writer = File.new("#{output_dir}/#{base_name}.rb", "w")
  base_name = base_name.capitalize

  writer.puts("class #{base_name}")
  writer.puts("  def accept(visitor) end")
  writer.puts("end")
  writer.puts

  defineVisitor(writer, base_name, types)

  types.each do |type|
    class_name = type.split(":")[0].strip
    fields = type.split(":")[1].strip
    defineType(writer, base_name, class_name, fields)
  end

  writer.close()
end

def defineType(writer, base_name, class_name, fields)
  accessors = fields.split.collect { |f| ":#{f}" }.join(", ")
  writer.puts("class #{class_name} < #{base_name}")
  writer.puts("    attr_accessor #{accessors}")
  writer.puts("    def accept(visitor)")
  writer.puts("        visitor.visit#{class_name}#{base_name}(self)")
  writer.puts("    end")
  writer.puts("end")
  writer.puts
end

def defineVisitor(writer, base_name, types)
  writer.puts("class Visitor")
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
  "Binary   : left operator right",
  "Grouping : expression",
  "Literal  : value",
  "Unary    : operator right"
])
