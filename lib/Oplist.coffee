defer           = require('node-promise').defer
lru             = require('lru')

lruopts =
  max: 10000
  maxAgeInMilliseconds: 1000 * 60 * 60 * 24 * 4

class Oplist

  constructor: (opts=lruopts) ->
    @lookup         = new lru(opts)
    @list           = {}
    @timelookup     = []
    @top            = undefined

  store: (something) =>
    timestamp = Date.now()
    #console.log 'storing at timestamp '+timestamp
    #console.dir something
    node = {timestamp: timestamp, next: undefined, value: something}
    if @top then @top.next = node
    @top = node
    @lookup.set(timestamp, node)
    @timelookup.push timestamp
    @last = @timelookup[@timelookup.length-1]
    @first = @timelookup[0]
    if @timelookup.length > lruopts.max then @timelookup.shift()
    timestamp

  retrieve: (fromTimestamp, howMany) =>
    #console.log 'retrieving from timestamp '+fromTimestamp+' first ts = '+@first+' last ts = '+@last
    rv = []
    if @first and @last
      if fromTimestamp < @first
        rv = [@lookup.get(@first).value]
      else if fromTimestamp > @last
        rv = [@lookup.get(@last).value]
      else
        entry = @_findEntryForTimestamp(fromTimestamp)
        if entry
          while entry and howMany-- > 0
            rv.push entry.value
            entry = entry.next
    rv

  #---------------------------------------------------------------------------------------------------------------------

  _findEntryForTimestamp: (timestamp) =>
    entry = @lookup.get(timestamp)
    if not entry
      nearestTimestamp = @_partitionAndFind(timestamp, @timelookup, 0, @timelookup.length)
      #console.log 'nearest timestamp was '+nearestTimestamp
      entry = @lookup.get(nearestTimestamp)
    entry

  _partitionAndFind: (target, array, start, end) ->
    diff = end-start
    midpoint = parseInt(end/2)
    compare = array[midpoint]
    #console.log '_partitionAndFind diff = '+diff+' start = '+start+' end = '+end+' target = '+target+' compare = '+compare
    if diff > 2
      if compare == target
        return compare
      else
        if compare < target
          _start = midpoint
          _end = end
        else
          _start = start
          _end = midpoint
        @_partitionAndFind(target, array, _start, _end)
    else
      return compare


module.exports = Oplist