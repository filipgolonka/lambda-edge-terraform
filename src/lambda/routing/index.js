'use strict';

exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;

    console.log(`Before replace: ${request.uri}`);

    if (request.uri.match(/^\/podcasts/)) {
        request.uri = request.uri.replace(/^\/podcasts\/?/, '/');
    } else if (request.uri.match(/^\/notifications/)) {
        request.uri = request.uri.replace(/^\/notifications\/?/, '/');
    }

    console.log(`After replace: ${request.uri}`);

    callback(null, request);
};
