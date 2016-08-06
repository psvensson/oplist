expect    = require("chai").expect
Oplist     = require('../lib/Oplist')
defer     = require('node-promise').defer

debug = process.env['DEBUG']
oplist = undefined
first = undefined
mid = undefined
last = undefined
saved = []

describe "Oplist test", ()->

  before (done)->
    oplist = new Oplist()
    count = 11
    for x in [0..10]
      ((_x)->
        setTimeout(
          ()->
            ts = oplist.store {foo: _x}
            saved.push {foo: _x}
            if --count == 0
              last = ts
              done()
            else if count == 5 then mid = ts
            else if count == 10 then first = ts
          ,10*x
        )
      )(x)



  #-----------------------------------------------------------------------------------------------------------------------

  it "should retrieve first item", (done)->
    res = oplist.retrieve(first, 1)
    expect(saved[0].foo).to.equal(res[0].foo)
    done()

  it "should retrieve last item", (done)->
    res = oplist.retrieve(last, 1)
    expect(saved[10].foo).to.equal(res[0].foo)
    done()

  it "should retrieve mid item", (done)->
    res = oplist.retrieve(mid, 1)
    expect(saved[5].foo).to.equal(res[0].foo)
    done()

  it "should retrieve several items", (done)->
    res = oplist.retrieve(mid, 4)
    expect(res.length).to.equal(4)
    done()

  it "should retrieve first item if stamp is to low", (done)->
    res = oplist.retrieve(first-1000, 1)
    expect(saved[0].foo).to.equal(res[0].foo)
    done()

  it "should retrieve last item if stamp is to high", (done)->
    res = oplist.retrieve(last+1000, 1)
    expect(saved[10].foo).to.equal(res[0].foo)
    done()

