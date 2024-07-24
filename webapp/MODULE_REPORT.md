## Module Report
### Unknown Global

**Global**: `Ember.onerror`

**Location**: `app/services/raven.js` at line 89

```js
  enableGlobalErrorCatching() {
    if (this.isRavenUsable && !this.globalErrorCatchingInitialized) {
      const _oldOnError = Ember.onerror;

      Ember.onerror = (error) => {
```

### Unknown Global

**Global**: `Ember.onerror`

**Location**: `app/services/raven.js` at line 89

```js
  enableGlobalErrorCatching() {
    if (this.isRavenUsable && !this.globalErrorCatchingInitialized) {
      const _oldOnError = Ember.onerror;

      Ember.onerror = (error) => {
```

### Unknown Global

**Global**: `Ember.onerror`

**Location**: `app/services/raven.js` at line 91

```js
      const _oldOnError = Ember.onerror;

      Ember.onerror = (error) => {
        if (this._ignoreError(error)) {
          return;
```
