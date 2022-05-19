module StmtVisitor
    def  visitBlockStmt (stmt)
        raise NotImplementedError
    end
    def  visitExpressionStmt (stmt)
        raise NotImplementedError
    end
    def  visitFunctionStmt (stmt)
        raise NotImplementedError
    end
    def  visitIfStmt (stmt)
        raise NotImplementedError
    end
    def  visitPrintStmt (stmt)
        raise NotImplementedError
    end
    def  visitVarStmt (stmt)
        raise NotImplementedError
    end
    def  visitWhileStmt (stmt)
        raise NotImplementedError
    end
end

class Block
    attr_accessor :statements
    def initialize(statements)
        @statements = statements
    end

    def accept(visitor)
        visitor.visitBlockStmt(self)
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

class Function
    attr_accessor :name, :params, :body
    def initialize(name, params, body)
        @name = name
        @params = params
        @body = body
    end

    def accept(visitor)
        visitor.visitFunctionStmt(self)
    end
end

class If
    attr_accessor :condition, :thenBranch, :elseBranch
    def initialize(condition, thenBranch, elseBranch)
        @condition = condition
        @thenBranch = thenBranch
        @elseBranch = elseBranch
    end

    def accept(visitor)
        visitor.visitIfStmt(self)
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

class While
    attr_accessor :condition, :body
    def initialize(condition, body)
        @condition = condition
        @body = body
    end

    def accept(visitor)
        visitor.visitWhileStmt(self)
    end
end

