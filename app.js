clientID = ''
clientSecret = ''

var async = require('async');
var app = require('express')();
var request = require('request');

app.use(require('body-parser').json());

app.post('/harmonize', function (req, res) {
  async.each(req.body, function(row, callback) {
    if (row.name !== '' && row.latitude != '' && row.latitude != 0 && row.longitude !== '' && row.longitude !== 0) {
      url = 'https://api.foursquare.com/v2/venues/search';
      qs = {
        client_id: clientID,
        client_secret: clientSecret,
        v: '20170101',
        intent: 'match',
        name: row.name,
        ll: row.latitude + ',' + row.longitude,
        address: row.address || '',
        city: row.city || '',
        state: row.state || '',
        zip: row.zip || '',
        country: row.country || '',
        phone: row.phone || ''
      };

      request({url: url, qs: qs}, function(error, response, body) {
        if (response.statusCode == 200) {
          data = JSON.parse(body);
          venues = data.response.venues || null;
          if ((venues != null) && venues.length > 0) {
            row.matchedID = venues[0].id;
            row.matchedName = venues[0].name;
            row.matchedAddress = venues[0].location.address;
            row.matchedCity = venues[0].location.city;
            row.matchedState = venues[0].location.state;
            row.matchedCountry = venues[0].location.country;
            row.matchedZip = venues[0].location.postalCode;
            row.matchedPhone = venues[0].contact.phone;
          }
        }
        callback();
      });
    } else {
      callback();
    }
  }, function(error) {
    res.json(req.body);
  });
});

app.listen(3000);
