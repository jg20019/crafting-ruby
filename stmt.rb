module StmtVisitor
    def  visitExpressionStmt (stmt)
        raise NotImplementedError
    end
    def  visitPrintStmt (stmt)
        raise NotImplementedError
    end
    def  visitVarStmt (stmt)
        raise NotImplementedError
    end
end

class Expression
    attr_accessor :expression
    def initialize(expression)
        @expression = expression
    end

    def accept(visitor)
        visitor.visitExpressionStmt(self)
    end
end

class Print
    attr_accessor :expression
    def initialize(expression)
        @expression = expression
    end

    def accept(visitor)
        visitor.visitPrintStmt(self)
    end
end

class Var
    attr_accessor :name, :initializer
    def initialize(name, initializer)
        @name = name
        @initializer = initializer
    end

    def accept(visitor)
        visitor.visitVarStmt(self)
    end
end

