const { handler: lambda } = require('../../../src/lambda/api-docs');

const createEvent = ({ uri, headers = {}, clientIp = '1.1.1.1' }) => ({
    Records: [
        {
            cf: {
                request: {
                    clientIp,
                    uri,
                    headers,
                },
            },
        },
    ],
});

const context = null;

describe('lambda/api-docs', () => {
    const callback = jest.fn();

    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('allows requests from certain ip', () => {
        const event = createEvent({ uri: '/docs/', clientIp: '89.70.8.16' });

        lambda(event, context, callback);

        expect(callback).toHaveBeenCalledWith(
            null,
            { clientIp: '89.70.8.16', headers: {}, uri: '/' }
        );
    });

    it('allows requests with Authorization header', () => {
        const event = createEvent({ uri: '/docs/', headers: { authorization: {} } });

        lambda(event, context, callback);

        expect(callback).toHaveBeenCalledWith(
            null,
            {
                clientIp: '1.1.1.1',
                headers: {
                    authorization: {},
                },
                uri: '/'
            }
        );
    });

    it('blocks other requests', () => {
        const event = createEvent({ uri: '/docs/' });

        lambda(event, context, callback);

        expect(callback).toHaveBeenCalledWith(
            null,
            {
                body: 'Unauthorized',
                headers: {
                    'content-type': [{
                        key: 'Content-Type',
                        value: 'text/plain',
                    }],
                },
                status: '401',
                statusDescription: 'Unauthorized',
            }
        );
    });
});
