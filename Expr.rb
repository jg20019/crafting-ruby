class Expr end

class Binary < Expr
    attr_accessor :left, :operator, :right
end
class Grouping < Expr
    attr_accessor :expression
end
class Literal < Expr
    attr_accessor :value
end
class Unary < Expr
    attr_accessor :operator, :right
end
