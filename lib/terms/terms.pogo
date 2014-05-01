class = require '../class'.class
class extending = require '../class'.class extending
_ = require 'underscore'
ms = require '../memorystream'
source map = require 'source-map'

buffer () =
    chunks = []
    {
        write (code) = chunks.push (code)
        chunks () = chunks
    }

module.exports (cg) =
    Node = class {
        cg = cg

        constructor (members) =
            if (members)
                for @(member) in (members)
                    if (members.has own property (member))
                        self.(member) = members.(member)

        set location (new location) =
            Object.defineProperty(self, '_location', value: new location, writable: true)

        location () =
            if (self._location)
                self._location
            else
                children = self.children ()

                locations = [c <- children, loc = c.location (), loc, loc]

                if (locations.length > 0)
                    first line = _.min [l <- locations, l.first line]
                    last line = _.max [l <- locations, l.last line]

                    locations on first line = [l <- locations, l.first line == first line, l]
                    locations on last line = [l <- locations, l.last line == last line, l]

                    {
                        first line = first line
                        last line = last line
                        first column = _.min [l <- locations on first line, l.first column]
                        last column = _.max [l <- locations on last line, l.last column]
                        filename = locations.0.filename
                    }
                else
                    nil

        clone (rewrite (subterm): nil, limit (subterm): false, create object (node): Object.create (Object.get prototype of (node))) =
            clone object (node, allow rewrite, path) =
                t = create object (node)

                for @(member) in (node)
                    if (node.has own property (member))
                        t.(member) = clone subterm (node.(member), allow rewrite, path)

                t

            clone node (original node, allow rewrite, path) =
                if (original node.dont clone)
                    original node
                else
                    try
                        path.push (original node)
                        rewritten node =
                            if ((original node :: Node) && allow rewrite)
                                sub clone (node) =
                                    if (node)
                                        clone subterm (node, allow rewrite, path)
                                    else
                                        clone object (original node, allow rewrite, path)

                                rewrite (
                                    original node
                                    path: path
                                    clone: sub clone
                                    rewrite: sub clone
                                )
                            else
                                nil

                        if (!rewritten node)
                            clone object (original node, allow rewrite, path)
                        else
                            if (!(rewritten node :: Node))
                                throw (new (Error "rewritten node not an instance of Node"))

                            rewritten node.is derived from (original node)
                            rewritten node
                    finally
                        path.pop ()
                
            clone array (terms, allow rewrite, path) =
                try
                    path.push (terms)
                    [node <- terms, clone subterm (node, allow rewrite, path)]
                finally
                    path.pop ()

            clone subterm (subterm, allow rewrite, path) =
                if (subterm :: Array)
                    clone array (subterm, allow rewrite, path)
                else if (subterm :: Function)
                    subterm
                else if (subterm :: Object)
                    clone node (subterm, allow rewrite && !limit (subterm, path: path), path)
                else
                    subterm
            
            clone subterm (self, true, [])

        is derived from (ancestor node) =
            self.set location (ancestor node.location ())

        rewrite (options) =
            options := options || {}
            options.create object (node) = node
            self.clone (options)

        children () =
            children = []

            add member (member) =
                if (member :: Node)
                    children.push (member)
                else if (member :: Array)
                    for each @(item) in (member)
                        add member (item)
                else if (member :: Object)
                    add members in object (member)

            add members in object (object) =
                for @(property) in (object)
                    if (object.has own property (property))
                        member = object.(property)

                        add member (member)

            add members in object (self)

            children

        walk descendants (walker, limit (): false) =
            path = []

            walk children (node) =
                try
                    path.push (node)
                    for each @(child) in (node.children ())
                        walker (child, path)
                        if (!limit (child, path))
                            walk children (child)
                finally
                    path.pop ()

            walk children (self)

        walk descendants (walker) not below if (limit) = self.walk descendants (walker, limit: limit)

        reduce with reduced children into (reducer, limit (term): false, cache name: nil) =
            path = []

            caching reducer =
                if (cache name)
                    @(node, reduced children)
                        if (node.has own property 'reductionCache')
                            if (node.reduction cache.has own property (cache name))
                                node.reduction cache.(cache name)
                        else
                            reduced value = reducer (node, reduced children)

                            if (!node.has own property 'reductionCache')
                                node.reduction cache = {}

                            node.reduction cache.(cache name) = reduced value

                            reduced value
                else
                    reducer

            map reduce children (node) =
                try
                    path.push (node)
                    mapped children = []
                    for each @(child) in (node.children ())
                        if (!limit (child, path))
                            mapped children.push (map reduce children (child))

                    caching reducer (node, mapped children)
                finally
                    path.pop ()

            map reduce children (self)
    }

    Term = class extending (Node) {
        arguments () = self

        inspect term (depth: 20) =
            util = require 'util'
            util.inspect (self, false, depth)

        show (desc: nil, depth: 20) =
            if (desc)
                console.log (desc, self.inspect term (depth: depth))
            else
                console.log (self.inspect term (depth: depth))

        hash entry () =
            self.cg.errors.add term (self) with message 'cannot be used as a hash entry'

        hash entry field () =
            self.cg.errors.add term (self) with message 'cannot be used as a field name'

        blockify (parameters, options) =
            self.cg.block (parameters, self.cg.async statements [self], options)

        scopify () = self

        parameter () =
            self.cg.errors.add term (self) with message 'this cannot be used as a parameter'

        subterms () = nil

        expand macro () = nil

        expand macros () =
            self.clone (
                rewrite (term, clone: nil): term.expand macro (clone)
            )

        rewrite statements () = nil

        rewrite all statements () =
            self.clone (
                rewrite (term, clone: nil): term.rewrite statements (clone)
            )

        serialise sub statements () = nil
        serialise statements () = nil
        serialise all statements () =
            self.rewrite (
                rewrite (term):
                    term.serialise statements ()
            )

        define variables () = nil
        canonical name () = nil

        make async with callback for result (create callback for result) = nil

        contains continuation () =
            found = false

            self.walk descendants @(term)
                found := term.is continuation @or found
            (limit (term): term.is closure @and term.is async)

            found

        contains async () =
            is async = false

            self.walk descendants @(term)
                is async := is async @or (term.is definition @and term.is async)
            (limit (term): term.is closure)

            is async

        rewrite result term into (return term) =
            if (self.contains continuation ())
                self
            else
                return term (self)

        asyncify () = nil

        code (chunks, ...) =
            location = self.location ()

            if (location)
                @new source map.Source Node (
                    location.first line
                    location.first column
                    location.filename
                    chunks
                )
            else
                chunks

        generate into buffer (generate code into buffer) =
            chunks = 
                b = buffer ()
                generate code into buffer (b)
                b.chunks ()

            location = self.location ()

            if (location)
                @new source map.Source Node (
                    location.first line
                    location.first column
                    location.filename
                    chunks
                )
            else
                chunks

        generate statement (scope) =
            self.code (self.generate (scope), ';')

        generate function (scope) =
            self.generate (scope)
    }

    term prototype = new (Term)

    term (members) =
        term constructor = class extending (Term, members)

        @(args, ...)
            new (term constructor (args, ...))

    {
        Node = Node
        Term = Term
        term = term
        term prototype = term prototype
    }
