declare module 'accent-webapp/utils/file-saver' {
  type FileSaver = (blob: Blob, fileName: string) => void;

  export function fileSaver(window: Window): FileSaver;
}
