
def defineAST(output_dir, base_name, types)
  writer = File.new("#{output_dir}/#{base_name}.rb", "w")

  writer.puts("class #{base_name} end")
  writer.puts

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
  writer.puts("end")
end

if ARGV.length != 1
  puts "Usage: generate_ast <output directory>"
  exit(64)
end

outputDir = ARGV[0]
defineAST(outputDir, "Expr", [
  "Binary   : left operator right",
  "Grouping : expression",
  "Literal  : value",
  "Unary    : operator right"
])
