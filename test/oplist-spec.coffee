expect    = require("chai").expect
Oplist     = require('../lib/Oplist')
defer     = require('node-promise').defer

debug = process.env['DEBUG']
oplist = undefined

describe "Tiler test", ()->

  before (done)->
    oplist = new Oplist()
    done()

  #-----------------------------------------------------------------------------------------------------------------------

  it "should work", (done)->
    expect(true).to.equal(true)
    done()

