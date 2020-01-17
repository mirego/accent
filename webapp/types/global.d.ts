// Types for compiled templates
declare module 'accent-webapp/templates/*' {
  import {TemplateFactory} from 'htmlbars-inline-precompile';
  const template: TemplateFactory;
  export default template;
}
