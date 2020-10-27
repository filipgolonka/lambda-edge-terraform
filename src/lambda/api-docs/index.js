'use strict';

const ALLOWED_IPS = ['89.70.8.16'];

exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;

    if (
        !ALLOWED_IPS.includes(request.clientIp)
        && !request.headers['authorization']
    ) {
        console.log(`Client ${request.clientIp} is not trusted or did not send Authorization header`);

        const response = {
            status: '401',
            statusDescription: 'Unauthorized',
            headers: {
                'content-type': [{
                    key: 'Content-Type',
                    value: 'text/plain'
                }]
            },
            body: 'Unauthorized',
        };

        return callback(null, response);
    }

    request.uri = request.uri.replace(/^\/docs\/?/, '/');

    console.log(`Request uri: ${request.uri}`);

    callback(null, request);
};
