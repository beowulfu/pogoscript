module.exports (terms) = terms.term {
    constructor (expr, implicit: false) =
        self.is return = true
        self.expression = expr
        self.is implicit = implicit

    generate statement (scope) =
        self.generate into buffer @(buffer)
            if (self.expression)
                buffer.write ('return ')
                buffer.write (self.expression.generate (scope))
                buffer.write (';')
            else
                buffer.write ('return;')
    
    rewrite result term into (return term, async: false) =
        if (async)
            arguments =
                if (self.expression)
                    [terms.nil (), self.expression]
                else
                    []

            terms.function call (terms.continuation function, arguments)
        else
            self
}
