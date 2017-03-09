clientID = process.env.FOURSQUARE_CLIENT_ID
clientSecret = process.env.FOURSQUARE_CLIENT_SECRET 

async = require 'async'
express = require 'express'
bp = require 'body-parser'
request = require 'request'

app = express()
app.use bp.json()
app.use express.static 'web'

app.post '/harmonize', (req, res) -> 
  async.each req.body, 
    (row, callback) -> 
      if row.name != '' and ((row.latitude != '' and row.longitude != '') or (row.city != '' and row.state != ''))
        url = 'https://api.foursquare.com/v2/venues/search'
        qs = 
          client_id: clientID
          client_secret: clientSecret
          v: '20170101'
          intent: 'match'
          name: row.name
          ll: row.latitude + ',' + row.longitude
          near: row.city + ',' + row.state
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

            row.matchedStatus = response.statusCode
            callback()
      else
        row.matchedStatus = 'invalid'
        callback()
    (error) ->
      res.json req.body

app.use (req, res) ->
  res.sendStatus 404

app.listen process.env.PORT or 8080
