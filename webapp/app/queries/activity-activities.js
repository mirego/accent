import gql from 'graphql-tag';

export default gql`
  query ActivityActivities($projectId: ID!, $activityId: ID!, $page: Int) {
    viewer {
      project(id: $projectId) {
        id

        activity(id: $activityId) {
          id

          operations(page: $page) {
            meta {
              totalEntries
              totalPages
              currentPage
              nextPage
              previousPage
            }

            entries {
              ...activitiesActivityFields

              revision {
                id
                name
                language {
                  id
                  name
                }
              }
            }
          }
        }
      }
    }
  }

  fragment activitiesActivityFields on Activity {
    id
    action
    text
    insertedAt

    user {
      id
      fullname
      pictureUrl
      isBot
    }

    translation {
      id
      key
    }

    stats {
      action
      count
    }

    document {
      id
      path
    }

    version {
      id
      tag
    }
  }
`;
