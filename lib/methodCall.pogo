codegen utils = require './codegenUtils'

module.exports (terms) =
    method call term = terms.term {
        constructor (object, name, args, optional args, async: false) =
            self.is method call = true
            self.object = object
            self.name = name
            self.method arguments = args
            self.optional arguments = optional args
            self.is async = async
              
        generate java script (buffer, scope) =
            self.object.generate java script (buffer, scope)
            buffer.write ('.')
            buffer.write (codegen utils.concat name (self.name))
            buffer.write ('(')
            codegen utils.write to buffer with delimiter (codegen utils.args and optional args (self.cg, self.method arguments, self.optional arguments), ',', buffer, scope)
            buffer.write (')')

        expand macro (clone) =
            if (self.is async)
                async result = terms.generated variable ['async', 'result']

                terms.sub statements [
                    terms.definition (
                        async result
                        clone ()
                        async: true
                    )
                    async result
                ]

        make async call with result (result variable, error variable, statements) =
            mc = self.clone ()
            mc.method arguments.push (terms.closure ([error variable, result variable], terms.statements (statements)))
            mc
    }

    method call (object, name, args, optional args, options) =
        splatted args = terms.splat arguments (args, optional args)
  
        if (splatted args)
            object var = terms.generated variable ['o']
            terms.sub statements [
              terms.definition (objectVar, object)
              terms.methodCall (
                terms.field reference (objectVar, name)
                ['apply']
                [object var, splatted args]
                options
              )
            ]
        else
            method call term (object, name, args, optional args, options)
