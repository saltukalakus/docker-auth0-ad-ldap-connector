var http = require("http");

http.createServer(function (request, response) {
    response.writeHead(200, {'Content-Type': 'text/plain'});
    response.end('OK\n');
}).listen(8080);

console.log('docker-auth0-ad-ldap-connector health check server running');