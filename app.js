var express = require('express')
var app = express()

app.post('/harmonize', function (request, response) {
  console.log('test')
})

app.listen(3000)
