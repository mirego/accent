import { defineConfig } from 'vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import { scopedCSS } from 'ember-scoped-css/vite';

export default defineConfig({
  plugins: [
    classicEmberSupport(),
    ember(),
    scopedCSS(),
    babel({
      babelHelpers: 'runtime',
      extensions,
    }),
  ],
});
