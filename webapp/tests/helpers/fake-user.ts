import config from 'accent-webapp/config/environment';

export function loginFakeUser() {
  localStorage.setItem(
    config.APP.LOCAL_STORAGE.SESSION_NAMESPACE,
    JSON.stringify({
      token: 'fake-token',
      user: {
        email: 'tony.stark@mirego.com',
        fullname: 'Tony Stark',
        id: 'some-id',
        pictureUrl: 'fake-picture-url',
      },
    })
  );
}

export function logoutFakeUser() {
  localStorage.removeItem(config.APP.LOCAL_STORAGE.SESSION_NAMESPACE);
}
