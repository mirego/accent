import {defineConfig} from 'vite';
import {extensions, classicEmberSupport, ember} from '@embroider/vite';
import {babel} from '@rollup/plugin-babel';
import {loadTranslations} from '@ember-intl/vite';
import {scopedCSS} from 'ember-scoped-css/vite';
import svgJar from '@svg-jar/plugin/vite';

export default defineConfig({
  build: {
    chunkSizeWarningLimit: Infinity,
  },
  plugins: [
    svgJar({target: 'ember', embedded: false, defaultSprite: 'unsafe-inline'}),
    scopedCSS(),
    classicEmberSupport(),
    ember(),
    babel({
      babelHelpers: 'runtime',
      extensions,
    }),
    loadTranslations(),
  ],
});
