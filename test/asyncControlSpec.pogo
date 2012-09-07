async = require '../lib/asyncControl'
should = require 'should'

describe 'async control functions'
    describe 'if'
        it 'calls the callback with the result of the then' @(done)
            async.if (true) @(callback)
                callback (nil, 'result')
            @(error, result)
                if (error)
                    done (error)
                else
                    result.should.equal 'result'
                    done ()

        it 'calls the callback with the error of the then' @(done)
            async.if (true) @(callback)
                callback 'error'
            @(error, result)
                try
                    error.should.equal 'error'
                    should.not.exist (result)
                    done ()
                catch @(ex)
                    done (ex)

        it 'calls the callback with the error when the then throws' @(done)
            async.if (true) @(callback)
                throw 'error'
            @(error, result)
                try
                    error.should.equal 'error'
                    should.not.exist (result)
                    done ()
                catch @(ex)
                    done (ex)

    describe 'if else'
        it 'calls the callback with the result of the then' @(done)
            async.if (true) @(callback)
                callback (nil, 'then result')
            else @(callback)
                callback (nil, 'else result')
            @(error, result)
                if (error)
                    done (error)
                else
                    result.should.equal 'then result'
                    done ()

        it 'calls the callback with the error of the then' @(done)
            async.if (true) @(callback)
                callback 'then error'
            else @(callback)
                callback (nil, 'else result')
            @(error, result)
                try
                    error.should.equal 'then error'
                    should.not.exist (result)
                    done ()
                catch @(ex)
                    done (ex)

        it 'calls the callback with the error when the then throws' @(done)
            async.if (true) @(callback)
                throw 'then error'
            else @(callback)
                callback (nil, 'else result')
            @(error, result)
                try
                    error.should.equal 'then error'
                    should.not.exist (result)
                    done ()
                catch @(ex)
                    done (ex)

        it 'calls the callback with the result of the else' @(done)
            async.if (false) @(callback)
                callback (nil, 'then result')
            else @(callback)
                callback (nil, 'else result')
            @(error, result)
                if (error)
                    done (error)
                else
                    result.should.equal 'else result'
                    done ()

        it 'calls the callback with the error of the else' @(done)
            async.if (false) @(callback)
                callback (nil, 'then result')
            else @(callback)
                callback 'else error'
            @(error, result)
                try
                    error.should.equal 'else error'
                    should.not.exist (result)
                    done ()
                catch @(ex)
                    done (ex)

        it 'calls the callback with the error when the else throws' @(done)
            async.if (false) @(callback)
                callback (nil, 'then result')
            else @(callback)
                throw 'else error'
            @(error, result)
                try
                    error.should.equal 'else error'
                    should.not.exist (result)
                    done ()
                catch @(ex)
                    done (ex)