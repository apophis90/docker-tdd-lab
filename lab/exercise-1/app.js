
var express = require('express')
var app = express()

var port = process.env.PORT

if(port == undefined || port == '') {
    console.log('PORT environment variable not set, falling back to port 3000 ...')
    port = 3000;
}

app.get('/', function(req, res) {
    res.send('Welcome to Docker Birthday!');
});

app.listen(port, function() {
    console.log('Node app is listening on port 8080 ...');
})