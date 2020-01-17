import Service from '@ember/service';
import {fileSaver} from 'accent-webapp/utils/file-saver';

export default class FileSaver extends Service {
  fileSaver = fileSaver(window);

  saveAs(blob: Blob, fileName: string) {
    return this.fileSaver(blob, fileName);
  }
}

declare module '@ember/service' {
  interface Registry {
    'file-saver': FileSaver;
  }
}
