_ = require "lodash"

module.exports =
  sumUp: (cmp, evt) ->
    nums = cmp.get('v.nums')
    sum = _.reduce nums, (sum, n) ->
      sum + Number(n)
    , 0
    cmp.set 'v.sum', sum