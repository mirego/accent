// Types
import {DocumentPath} from '../types/document-path'
import {Project} from '../types/project'
import Document from './document'

export default class DocumentJiptPathsFetcher {
  public fetch(
    project: Project,
    document: Document,
    pseudoLanguageName: string
  ): DocumentPath[] {
    return project.documents.entries
      .map(({path}) => path)
      .map(path => {
        const parsedTarget = document.target
          .replace('%slug%', pseudoLanguageName)
          .replace('%original_file_name%', path)

        return {
          documentPath: path,
          language: pseudoLanguageName,
          path: parsedTarget
        }
      })
  }
}
