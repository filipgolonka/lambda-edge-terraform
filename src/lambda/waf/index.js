'use strict';

exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;

    if (request.querystring.match(/code=.+/)) {
        console.log(`WAF blocks code request, query string: ${request.querystring}`);

        const response = {
            status: '404',
            statusDescription: 'Not found',
            headers: {
                'content-type': [{
                    key: 'Content-Type',
                    value: 'text/plain'
                }]
            },
            body: 'Not found',
        };

        return callback(null, response);
    }
    console.log(request.querystring);

    callback(null, request);
};
