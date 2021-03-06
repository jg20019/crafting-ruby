module ExprVisitor
    def  visitAssignExpr (expr)
        raise NotImplementedError
    end
    def  visitBinaryExpr (expr)
        raise NotImplementedError
    end
    def  visitCallExpr (expr)
        raise NotImplementedError
    end
    def  visitGroupingExpr (expr)
        raise NotImplementedError
    end
    def  visitLiteralExpr (expr)
        raise NotImplementedError
    end
    def  visitLogicalExpr (expr)
        raise NotImplementedError
    end
    def  visitUnaryExpr (expr)
        raise NotImplementedError
    end
    def  visitVariableExpr (expr)
        raise NotImplementedError
    end
end

class Assign
    attr_accessor :name, :value
    def initialize(name, value)
        @name = name
        @value = value
    end

    def accept(visitor)
        visitor.visitAssignExpr(self)
    end
end

class Binary
    attr_accessor :left, :operator, :right
    def initialize(left, operator, right)
        @left = left
        @operator = operator
        @right = right
    end

    def accept(visitor)
        visitor.visitBinaryExpr(self)
    end
end

class Call
    attr_accessor :callee, :paren, :arguments
    def initialize(callee, paren, arguments)
        @callee = callee
        @paren = paren
        @arguments = arguments
    end

    def accept(visitor)
        visitor.visitCallExpr(self)
    end
end

class Grouping
    attr_accessor :expression
    def initialize(expression)
        @expression = expression
    end

    def accept(visitor)
        visitor.visitGroupingExpr(self)
    end
end

class Literal
    attr_accessor :value
    def initialize(value)
        @value = value
    end

    def accept(visitor)
        visitor.visitLiteralExpr(self)
    end
end

class Logical
    attr_accessor :left, :operator, :right
    def initialize(left, operator, right)
        @left = left
        @operator = operator
        @right = right
    end

    def accept(visitor)
        visitor.visitLogicalExpr(self)
    end
end

class Unary
    attr_accessor :operator, :right
    def initialize(operator, right)
        @operator = operator
        @right = right
    end

    def accept(visitor)
        visitor.visitUnaryExpr(self)
    end
end

class Variable
    attr_accessor :name
    def initialize(name)
        @name = name
    end

    def accept(visitor)
        visitor.visitVariableExpr(self)
    end
end

