// Types
import {DocumentPath} from '../types/document-path'
import {Project} from '../types/project'
import Document from './document'

export default class DocumentPathsFetcher {
  public fetch(project: Project, document: Document): DocumentPath[] {
    const languageSlugs = project.revisions.map(({language}) => language.slug)
    const documentPaths = project.documents.entries.map(({path}) => path)
    return languageSlugs.reduce((memo: DocumentPath[], slug) => {
      documentPaths.forEach(path => {
        const parsedTarget = document.target
          .replace('%slug%', slug)
          .replace('%original_file_name%', path)

        memo.push({documentPath: path, path: parsedTarget, language: slug})
      })

      return memo
    }, [])
  }
}
