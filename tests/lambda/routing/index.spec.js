const { handler: lambda } = require('../../../src/lambda/routing');

const createEvent = ({ uri }) => ({
    Records: [
        {
            cf: {
                request: {
                    uri,
                },
            },
        },
    ],
});

const context = null;

describe('lambda/routing', () => {
    const callback = jest.fn();

    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('rewrites podcasts in uri', () => {
        const event = createEvent({ uri: '/podcasts/' });

        lambda(event, context, callback);

        expect(callback).toHaveBeenCalledWith(
            null,
            {
                uri: '/',
            },
        );
    });

    it('rewrites notifications in uri', () => {
        const event = createEvent({ uri: '/notifications/' });

        lambda(event, context, callback);

        expect(callback).toHaveBeenCalledWith(
            null,
            {
                uri: '/',
            },
        );
    });

    it('leaves uri unchanged', () => {
        const event = createEvent({ uri: '/foo/' });

        lambda(event, context, callback);

        expect(callback).toHaveBeenCalledWith(
            null,
            {
                uri: '/foo/',
            },
        );
    });
});
