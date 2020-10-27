const { handler: lambda } = require('../../../src/lambda/waf');

const createEvent = ({ uri, querystring }) => ({
    Records: [
        {
            cf: {
                request: {
                    uri,
                    querystring,
                },
            },
        },
    ],
});

const context = null;

describe('lambda/waf', () => {
    const callback = jest.fn();

    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('blocks requests with code query param', () => {
        const event = createEvent({ querystring: 'foo=bar&code=1' });

        lambda(event, context, callback);

        expect(callback).toHaveBeenCalledWith(
            null,
            {
                body: 'Not found',
                headers: {
                    'content-type': [{
                        key: 'Content-Type',
                        value: 'text/plain',
                    }],
                },
                status: '404',
                statusDescription: 'Not found',
            }
        );
    });

    it('does not block other requests', () => {
        const event = createEvent({ querystring: 'foo=bar', uri: '/' });

        lambda(event, context, callback);

        expect(callback).toHaveBeenCalledWith(
            null,
            {
                querystring: 'foo=bar',
                uri: '/',
            },
        );
    });
});
