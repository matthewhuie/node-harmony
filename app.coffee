async = require 'async'
express = require 'express'
bp = require 'body-parser'
request = require 'request'

app = express()
app.use bp.json
  limit: '50mb'
app.use express.static 'web'

app.post '/harmonize', (req, res) -> 
  async.each req.body, 
    row.matchedID = '' 
    row.matchedName = ''
    row.matchedAddress = ''
    row.matchedCity = ''
    row.matchedState = ''
    row.matchedCountry = ''
    row.matchedZip = ''
    row.matchedPhone = ''
    row.matchedCategory = ''
  
    (row, callback) -> 
      if row.name != '' 
        url = 'https://api.foursquare.com/v2/venues/search'
        if row.latitude? and row.latitude != 0 and row.longitude? and row.longitude != 0 
          ll = row.latitude + ',' + row.longitude 
        else 
          near = row.city + ',' + row.state
        qs = 
          client_id: process.env.FOURSQUARE_CLIENT_ID 
          client_secret: process.env.FOURSQUARE_CLIENT_SECRET 
          v: '20170101'
          intent: 'match'
          name: row.name
          ll: ll || '0,0'
          near: near || ''
          address: row.address || ''
          city: row.city || ''
          state: row.state || ''
          zip: row.zip || ''
          country: row.country || ''
          phone: row.phone || ''

        request 
          url: url
          qs: qs
          (error, response, body) -> 
            if response?
              if response.statusCode == 200
                data = JSON.parse body
                venues = data.response.venues or null
                if (venues? and venues.length > 0)
                  row.matchedID = venues[0].id
                  row.matchedName = venues[0].name
                  row.matchedAddress = venues[0].location.address
                  row.matchedCity = venues[0].location.city
                  row.matchedState = venues[0].location.state
                  row.matchedCountry = venues[0].location.country
                  row.matchedZip = venues[0].location.postalCode
                  row.matchedPhone = venues[0].contact.phone
                  row.matchedCategory = venues[0].categories[0].name if venues[0].categories[0]?
              row.matchedStatus = response.statusCode
            else
              row.matchedStatus = 'failed'

            callback()
      else
        row.matchedStatus = 'invalid'
        callback()
    (error) ->
      res.json req.body

app.use (req, res) ->
  res.sendStatus 404

app.listen process.env.PORT or 8080
