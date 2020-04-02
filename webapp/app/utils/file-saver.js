// the Blob API is fundamentally broken as there is no "downloadfinished" event to subscribe to
const arbitraryRevokeTimeout = 1000 * 40; // eslint-disable-line no-magic-numbers
const bomCharCode = 0xfeff;

export const fileSaver = (view) => {
  const doc = view.document;

  // only get URL when necessary in case Blob.js hasn't overridden it yet
  const getURL = () => view.URL || view.webkitURL || view;
  const saveLink = doc.createElementNS('http://www.w3.org/1999/xhtml', 'a');
  const canUseSaveLink = 'download' in saveLink;
  const click = (node) => node.dispatchEvent(new MouseEvent('click'));
  const isSafari = /constructor/i.test(view.HTMLElement) || view.safari;
  const isChromeIos = /CriOS\/[\d]+/.test(navigator.userAgent);
  const throwOutside = (ex) => {
    (view.setImmediate || view.setTimeout)(() => {
      throw ex;
    }, 0);
  };
  const forceSaveableType = 'application/octet-stream';

  const revoke = (file) => {
    const revoker = () => {
      if (typeof file === 'string') {
        // file is an object URL
        getURL().revokeObjectURL(file);
      } else {
        // file is a File
        file.remove();
      }
    };

    setTimeout(revoker, arbitraryRevokeTimeout);
  };

  const dispatch = (filesaver, eventTypes, event) => {
    eventTypes = [].concat(eventTypes);
    let i = eventTypes.length;
    while (i--) {
      const listener = filesaver[`on${eventTypes[i]}`];
      if (typeof listener === 'function') {
        try {
          listener.call(filesaver, event || filesaver);
        } catch (ex) {
          throwOutside(ex);
        }
      }
    }
  };

  const autoBom = (blob) => {
    // prepend BOM for UTF-8 XML and text/* types (including HTML)
    // note: your browser will automatically convert UTF-16 U+FEFF to EF BB BF
    if (
      /^\s*(?:text\/\S*|application\/xml|\S*\/\S*\+xml)\s*;.*charset\s*=\s*utf-8/i.test(
        blob.type
      )
    ) {
      return new Blob([String.fromCharCode(bomCharCode), blob], {
        type: blob.type,
      });
    }
    return blob;
  };

  const FileSaver = function (blob, name, noAutoBom) {
    if (!noAutoBom) blob = autoBom(blob);

    // First try a.download, then web filesystem, then object URLs
    const filesaver = this;
    const type = blob.type;
    const force = type === forceSaveableType;
    let objectURL;
    const dispatchAll = () =>
      dispatch(filesaver, 'writestart progress write writeend'.split(' '));

    // on any filesys errors revert to saving with object URLs
    /* eslint-disable complexity */
    const fsError = () => {
      if ((isChromeIos || (force && isSafari)) && view.FileReader) {
        // Safari doesn't allow downloading of blob urls
        const reader = new FileReader();

        reader.onloadend = () => {
          let url = isChromeIos
            ? reader.result
            : reader.result.replace(/^data:[^;]*;/, 'data:attachment/file;');
          const popup = view.open(url, '_blank');
          if (!popup) view.location.href = url;
          url = undefined; // version reference before dispatching
          filesaver.readyState = filesaver.DONE;
          dispatchAll();
        };

        reader.readAsDataURL(blob);
        filesaver.readyState = filesaver.INIT;
        return;
      }

      // Don't create more object URLs than needed
      if (!objectURL) objectURL = getURL().createObjectURL(blob);

      if (force) {
        view.location.href = objectURL;
      } else {
        const opened = view.open(objectURL, '_blank');
        if (!opened) {
          // Apple does not allow window.open, see https://developer.apple.com/library/safari/documentation/Tools/Conceptual/SafariExtensionGuide/WorkingwithWindowsandTabs/WorkingwithWindowsandTabs.html
          view.location.href = objectURL;
        }
      }
      /* eslint-enable complexity */

      filesaver.readyState = filesaver.DONE;
      dispatchAll();
      revoke(objectURL);
    };

    filesaver.readyState = filesaver.INIT;

    if (canUseSaveLink) {
      objectURL = getURL().createObjectURL(blob);
      setTimeout(() => {
        saveLink.href = objectURL;
        saveLink.download = name;
        click(saveLink);
        dispatchAll();
        revoke(objectURL);
        filesaver.readyState = filesaver.DONE;
      });
      return;
    }

    fsError();
  };

  const FSproto = FileSaver.prototype;

  // IE 10+ (native saveAs)
  if (typeof navigator !== 'undefined' && navigator.msSaveOrOpenBlob) {
    return (blob, name, noAutoBom) => {
      name = name || blob.name || 'download';

      if (!noAutoBom) blob = autoBom(blob);
      return navigator.msSaveOrOpenBlob(blob, name);
    };
  }

  FSproto.abort = () => {};
  FSproto.readyState = FSproto.INIT = 0;
  FSproto.WRITING = 1;
  FSproto.DONE = 2;

  FSproto.error = FSproto.onwritestart = FSproto.onprogress = FSproto.onwrite = FSproto.onabort = FSproto.onerror = FSproto.onwriteend = null;

  return (blob, name, noAutoBom) =>
    new FileSaver(blob, name || blob.name || 'download', noAutoBom);
};
