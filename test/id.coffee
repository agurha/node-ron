
should = require 'should'

try config = require '../conf/test' catch e
Ron = require '../index'

describe 'id', ->

    ron = User = null
    
    before (next) ->
        ron = Ron config
        User = ron.define 'users'
        User.identifier 'user_id'
        User.unique 'username'
        User.index 'email'
        next()

    beforeEach (next) ->
        User.clear next
    
    after (next) ->
        ron.quit next

    it 'Test id # number', (next) ->
        User.id 3, (err, userId) ->
            should.not.exist err
            userId.should.eql 3
            User.id [3], (err, userId) ->
                should.not.exist err
                userId.should.eql [3]
                next()

    it 'Test id # user.user_id', (next) ->
        User.id {user_id: 3}, (err, userId) ->
            should.not.exist err
            userId.should.eql 3
            User.id [{user_id: 3, username: 'my_username'}], (err, userId) ->
                should.not.exist err
                userId.should.eql [3]
                next()

    it 'Test id # user.username', (next) ->
        User.create
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        , (err, user) ->
            # Pass an object
            User.id {username: 'my_username'}, (err, userId) ->
                should.not.exist err
                userId.should.eql user.user_id
                # Pass an array of ids and objects
                User.id [1, {username: 'my_username'}, 2], (err, userId) ->
                    should.not.exist err
                    userId.should.eql [1, user.user_id, 2]
                    User.clear next

    it 'Test id # invalid object empty', (next) ->
        # Test an array of 3 arguments, 
        # but the second is invalid since it's an empty object
        User.id [1, {}, {user_id: 2}], (err, user) ->
            err.message.should.eql 'Invalid object, got {}'
            User.id {}, (err, user) ->
                err.message.should.eql 'Invalid object, got {}'
                User.clear next

    it 'Test id # missing unique', (next) ->
        # Test an array of 3 arguments, 
        # but the second is invalid since it's an empty object
        User.create [
            { username: 'my_username_1', email: 'my1@mail.com' }
            { username: 'my_username_2', email: 'my2@mail.com' }
        ], (err, users) ->
            # Test return id
            User.id [
                { username: users[1].username }     # By unique
                { user_id: users[0].user_id }       # By identifier
                { username: 'who are you' }         # Alien
            ], (err, result) ->
                result[0].should.eql users[1].user_id
                result[1].should.eql users[0].user_id
                should.not.exist result[2]
                User.clear next

    it 'Test id # missing unique + option object', (next) ->
        # Test an array of 3 arguments, 
        # but the second is invalid since it's an empty object
        User.create [
            { username: 'my_username_1', email: 'my1@mail.com' }
            { username: 'my_username_2', email: 'my2@mail.com' }
        ], (err, users) ->
            User.id [
                { username: users[1].username }     # By unique
                { user_id: users[0].user_id }       # By identifier
                { username: 'who are you' }         # Alien
            ], {object: true}, (err, result) ->
                # Test return object
                result[0].user_id.should.eql users[1].user_id
                result[1].user_id.should.eql users[0].user_id
                should.not.exist result[2].user_id
                User.clear next

    it 'Test id # invalid type id', (next) ->
        # Test an array of 3 arguments, 
        # but the second is invalid since it's a boolean
        User.id [1, true, {user_id: 2}], (err, user) ->
            err.message.should.eql 'Invalid id, got true'
            User.id false, (err, user) ->
                err.message.should.eql 'Invalid id, got false'
                User.clear next

    it 'Test id # invalid type null', (next) ->
        # Test an array of 3 arguments, 
        # but the second is invalid since it's a boolean
        User.id [1, null, {user_id: 2}], (err, users) ->
            err.message.should.eql 'Invalid object, got null'
            User.id null, (err, user) ->
                err.message.should.eql 'Invalid object, got null'
                User.clear next

    it 'Test id # accept null', (next) ->
        # Test an array of 3 arguments, 
        # but the second is invalid since it's a boolean
        User.id [1, null, {user_id: 2}], {accept_null: true}, (err, users) ->
            should.not.exist err
            users.length.should.eql 3
            should.exist users[0]
            should.not.exist users[1]
            should.exist users[2]
            # Test null
            User.id null, {accept_null: true}, (err, user) ->
                should.not.exist err
                should.not.exist user
                User.clear next

    it 'Test id # accept null return object', (next) ->
        # Same test than 'Test id # accept null' with the 'object' option
        User.id [1, null, {user_id: 2}], {accept_null: true, object: true}, (err, users) ->
            should.not.exist err
            users.length.should.eql 3
            users[0].user_id.should.eql 1
            should.not.exist users[1]
            users[2].user_id.should.eql 2
            # Test null
            User.id null, {accept_null: true, object: true}, (err, user) ->
                should.not.exist err
                should.not.exist user
                User.clear next

    it 'Test id # id return object', (next) ->
        User.create {
            username: 'my_username'
            email: 'my@email.com'
            password: 'my_password'
        }, (err, orgUser) ->
            # Pass an id
            User.id orgUser.user_id, {object: true}, (err, user) ->
                should.not.exist err
                user.should.eql {user_id: orgUser.user_id}
                # Pass an array of ids
                User.id [orgUser.user_id, orgUser.user_id], {object: true}, (err, user) ->
                    user.should.eql [{user_id: orgUser.user_id}, {user_id: orgUser.user_id}]
                    User.clear next

    it 'Test id # unique + option object', (next) ->
        User.create {
            username: 'my_username'
            email: 'my@email.com'
            password: 'my_password'
        }, (err, orgUser) ->
            # Pass an object
            User.id {username: 'my_username'}, {object: true}, (err, user) ->
                should.not.exist err
                user.should.eql {username: 'my_username', user_id: orgUser.user_id}
                # Pass an array of ids and objects
                User.id [1, {username: 'my_username'}, 2], {object: true}, (err, user) ->
                    should.not.exist err
                    user.should.eql [{user_id: 1}, {username: 'my_username', user_id: orgUser.user_id}, {user_id: 2}]
                    User.clear next