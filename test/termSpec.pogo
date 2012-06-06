cg = require '../src/bootstrap/codeGenerator/codeGenerator'.code generator ()
require './assertions'
term = require '../lib/terms'.term
_ = require 'underscore'

terms (subterms) ... =
    cg.term =>
        self.terms = subterms
        
        self.subterms 'terms'
        
branch (left, right) =
    cg.term =>
        self.left = left
        self.right = right
        
        self.subterms 'left' 'right'

(actual list) should only have (expected list) =
    actual list.length.should.equal (expected list.length)

    for each @(item) in (expected list)
        _.include(actual list, item).should.be

leaf (name) =
    cg.term =>
        self.name = name

location (fl, ll, fc, lc) = {
    first_line = fl
    last_line = ll
    first_column = fc
    last_column = lc
}

/* terms:
  
   terms are objects (aka hashes)
   terms can contain arrays, numbers and strings, or other things, but
   only objects are terms.
  
   terms can have prototypes, in in fact prototypes are where terms
   get most of their behaviour.

   Terms can be cloned. This means that their prototype is copied,
   as well as any subterms (object fields). Arrays are copied too.

   Terms can have a location. And terms that derive from that term
   take a copy of that location, so they can be traced back to the
   originating source code.

   Terms can be derived from another term.

   Terms can be rewritten while they are cloned. Rewriting a term
   effectively derives the term's rewrite.
*/

describe 'terms'
    describe 'cloning'
        it 'creates a new object'
            t = new (term)

            new term = t.clone ()

            new term.should.not.equal (t)

        it 'copies all members when cloning'
            t = new (term)
            t.a = 1
            t.b = "b"

            clone = t.clone ()
            (clone) should contain fields {
                a = 1
                b = "b"
            }

        it 'arrays are also cloned'
            t = new (term)
            t.array = [1]

            clone = t.clone ()
            
            clone.array.should.not.equal (t.array)
            (clone) should contain fields {
                array = [1]
            }

        it "an object's prototype is also copied"
            t = new (term)
            t.a = 'a'

            clone = t.clone ()
            Object.get prototype of (clone).should.equal (Object.get prototype of (t))

        it "clones sub-objects"
            t = new (term)
            t.a = {name = "jack"}

            clone = t.clone ()
            
            (clone) should contain fields {
                a = {name = "jack"}
            }

        it "can rewrite an object while being cloned"
            t = new (term)
            t.a = new (term {name = "jack"})

            clone = t.clone (
                rewrite (old term):
                    if (old term.name)
                        new term = new (term)
                        new term.name = "jill"
                        new term
            )
            
            (clone) should contain fields {
                a = {name = "jill"}
            }

        it "doesn't rewrite beyond rewrite limit"
            t = new (term {
                a = new (term {name = "jack"})
                b = new (term {
                    is limit
                    c = new (term {name = "jack"})
                })
                d = new (term {name = "jason"})
            })

            clone = t.clone (
                rewrite (old term):
                    if (old term.name)
                        new (term {name = "jill"})

                limit (t):
                    t.is limit
            )
            
            (clone) should contain fields {
                a = {name = "jill"}
                b = {
                    c = {name = "jack"}
                }
                d = {name = "jill"}
            }

        it "throws an exception when the new term is not an instance of 'term'"
            t = new (term)
            t.a = new (term {name = "jack"})

            @{t.clone (
                rewrite (old term):
                    if (old term.name)
                        {name = "jill"}
            )}.should.throw "rewritten term not an instance of term"
            
        it 'copies the location when a term is rewritten'
            t = new (term)
            t.set location {first line = 1, last line = 1, first column = 20, last column = 30}
            
            clone = t.clone (
                rewrite (old term): 
                    t = new (term)
                    t.rewritten = true
                    t
            )

            (clone) should contain fields {
                rewritten = true
            }
            (clone.location ()) should contain fields {
                first line = 1
                last line = 1
                first column = 20
                last column = 30
            }

    describe 'location'
        it 'can set location'
            t = new (term)
            t.set location {first line = 1, last line = 2, first column = 20, last column = 30}

            (t.location ()) should contain fields {
                first line = 1
                last line = 2
                first column = 20
                last column = 30
            }

        it 'can compute location from children, first column is from first line, last column is from last line'
            left = new (term)
            left.set location {first line = 1, last line = 2, first column = 20, last column = 30}

            right = new (term)
            right.set location {first line = 2, last line = 4, first column = 30, last column = 10}

            t = new (term {
                left = left
                right = right
            })

            (t.location ()) should contain fields {
                first line = 1
                last line = 4
                first column = 20
                last column = 10
            }

        it 'can compute location from children, smallest first column, largest last column when on same line'
            left = new (term)
            left.set location {first line = 1, last line = 2, first column = 20, last column = 30}

            right = new (term)
            right.set location {first line = 1, last line = 2, first column = 10, last column = 40}

            t = new (term {
                left = left
                right = right
            })

            (t.location ()) should contain fields {
                first line = 1
                last line = 2
                first column = 10
                last column = 40
            }

    describe 'children'
        it 'returns immediate subterms'
            a = new (term)
            b = new (term)

            t = new (term {
                a = a
                b = b
            })

            (t.children ()) should only have [a, b]

    describe 'children'
        it 'returns terms in arrays'
            a = new (term)
            b = new (term)

            t = new (term {
                array = [a, b]
            })

            (t.children ()) should only have [a, b]

    describe 'children'
        it 'returns terms in objects'
            a = new (term)
            b = new (term)

            t = new (term {
                array = {a = a, b = b}
            })

            (t.children ()) should only have [a, b]

    describe 'walk descendants'
        it "walks descendants, children, children's children, etc"
            b = new (term)
            c = new (term)
            d = new (term)
            a = new (term {
                c = c
                d = [d]
            })

            t = new (term {
                a = a
                b = b
            })

            descendants = []

            t.walk descendants @(subterm)
                descendants.push (subterm)

            (descendants) should only have [a, b, c, d]

describe 'old terms'
    it 'subterms'
        term = cg.term =>
            self.a = cg.identifier 'a'
            self.b = cg.identifier 'b'
            self.subterms 'a' 'b'
        
        (term.all subterms ()) should contain fields [
            {identifier 'a'}
            {identifier 'b'}
        ]

    describe 'rewriting'
        it 'can rewrite subterms'
            term = cg.term =>
                self.a = cg.identifier 'a'
                self.b = cg.identifier 'b'

                self.subterms 'a' 'b'

            term.rewrite @(term)
                if (term.is identifier && (term.identifier == 'b'))
                    cg.identifier 'z'

            (term) should contain fields {
                a {identifier 'a'}
                b {identifier 'z'}
            }

        it 'can rewrite subterms in lists'
            term = cg.term =>
                self.things = [cg.identifier 'a', cg.identifier 'b']

                self.subterms 'things'

            term.rewrite @(term)
                if (term.is identifier && (term.identifier == 'b'))
                    cg.identifier 'z'

            (term) should contain fields {
                things [{identifier 'a'}, {identifier 'z'}]
            }

        it "doesn't rewrite subterms that aren't objects"
            term = cg.term =>
                self.things = [cg.identifier 'a', null, nil, 0, 1.1, "one", ""]
                self.a = 6
                self.b = {x = 5}

                self.subterms 'things' 'a' 'b'

            terms rewritten = []

            term.rewrite @(term)
                terms rewritten.push (term)

            (terms rewritten) should contain fields [
                {identifier 'a'}
                {x = 5}
            ]

        it "rewrites lists of lists of terms"
            term = cg.term =>
                self.things = [cg.identifier 'a', [cg.identifier 'b', [cg.identifier 'c']]]

                self.subterms 'things'

            term.rewrite @(term)
                if (term.is identifier && (term.identifier == 'c'))
                    cg.identifier 'z'

            (term) should contain fields {
                things [{identifier 'a'}, [{identifier 'b'}, [{identifier 'z'}]]]
            }

        it 'rewrites deep into the graph'
            subterm = cg.term =>
                self.a = cg.identifier 'a'
                self.subterms 'a'

            term = cg.term =>
                self.thing = subterm
                self.subterms 'thing'

            term.rewrite @(term)
                if (term.is identifier && (term.identifier == 'a'))
                    cg.identifier 'z'

            (term) should contain fields {
                thing {
                    a = {identifier 'z'}
                }
            }

        it "doesn't rewrite beyond limit"
            subterm = cg.term =>
                self.is subterm = true
                self.a = cg.identifier 'a'
                self.subterms 'a'

            term = cg.term =>
                self.thing = subterm
                self.b = cg.identifier 'b'
                self.subterms 'thing' 'b'

            term.rewrite (limit (term) if: term.is subterm) @(term)
                if (term.is identifier)
                    cg.identifier 'z'

            (term) should contain fields {
                thing {
                    a = {identifier 'a'}
                }
                b = {identifier 'z'}
            }
    
    describe 'locations'
        it 'location'
            id = cg.loc (cg.identifier 'a', location 1 2 3 4)
            
            (id.location ()) should contain fields {
                first line 1
                last line 2
                first column 3
                last column 4
            }
        
        it "aggregates locations of subterms if it doesn't have a location itself"
            term = cg.term
                this.a = cg.loc (cg.identifier 'a', location 1 1 3 10)
                this.b = cg.loc (cg.identifier 'b', location 1 1 2 12)
                this.subterms 'a' 'b'

            (term.location ()) should contain fields {
                first line 1
                last line 1
                first column 2
                last column 12
            }
    
    it 'derived term'
        a = cg.loc (leaf 'a', location 1 1 2 8)
        b = cg.loc (leaf 'b', location 2 2 2 8)

        term = branch (a, b)
        c = term.derived term (leaf 'c')

        (c.location ()) should contain fields {
            first line 1
            last line 2
            first column 2
            last column 8
        }

    describe 'depth first walk'
        root = terms (branch (leaf 'a', leaf 'b'), branch (leaf 'c', branch (leaf 'd', leaf 'e')))
        
        it 'walks all terms depth first'
            leaf terms = []
        
            root.walk descendants @(term)
                if (term.name)
                    leaf terms.push (term.name)

            (leaf terms) should contain fields ['a', 'b', 'c', 'd', 'e']

        it "doesn't walk undefined subterms"
            term = branch (leaf 'a', undefined)
            
            leaf terms = []
            
            term.walk descendants @(term)
                leaf terms.push (term)
            
            (leaf terms) should contain fields [{name 'a'}]
