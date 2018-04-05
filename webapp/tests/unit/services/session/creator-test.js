import { expect } from 'chai';
import {
  describeModule,
  it,
  beforeEach,
  afterEach
} from 'ember-mocha';
import sinon from 'sinon';

const HTTP_STATUS = {
  'ok': 200
};

describeModule(
  'service:session/creator',
  'service:session/creator',
  {
    needs: []
  },
  () => {
    let xhr;
    let requests;
    let service;

    beforeEach(() => {
      xhr = sinon.useFakeXMLHttpRequest();
      requests = [];
      xhr.onCreate = (request) => requests.push(request);

      service = this.subject();
    });

    afterEach(() => {
      xhr.restore();
    });

    it('should return a promise', () => {
      expect(service.createSession({username: 'test@mirego.com'})).to.respondTo('then');
    });

    it('should resolve with the credentials returned from the API', (done) => {
      const credentialsJSON = '{"user":{"email":"test@mirego.com"},"token":"abc123"}';

      service.createSession({username: 'test@mirego.com'}).then((credentials) => {
        expect(credentials).to.deep.equal(JSON.parse(credentialsJSON));
        done();
      });

      requests[0].respond(HTTP_STATUS.ok, {'Content-Type': 'application/json'}, credentialsJSON);
    });
  }
);
