import {gql} from '@apollo/client/core';

export default gql`
  query IntegrationExecutions($projectId: ID!, $page: Int) {
    viewer {
      project(id: $projectId) {
        id
        name

        integrations {
          id
          service

          ... on ProjectIntegrationDiscord {
            lastExecutedAt
            data {
              id
              url
            }
            integrationExecutions(page: $page) {
              meta {
                totalEntries
                totalPages
                currentPage
                nextPage
                previousPage
              }
              entries {
                id
                state
                data
                results
                insertedAt
                user {
                  id
                  email
                  fullname
                  pictureUrl
                }
                version {
                  id
                  tag
                }
              }
            }
          }

          ... on ProjectIntegrationSlack {
            lastExecutedAt
            data {
              id
              url
            }
            integrationExecutions(page: $page) {
              meta {
                totalEntries
                totalPages
                currentPage
                nextPage
                previousPage
              }
              entries {
                id
                state
                data
                results
                insertedAt
                user {
                  id
                  email
                  fullname
                  pictureUrl
                }
                version {
                  id
                  tag
                }
              }
            }
          }

          ... on ProjectIntegrationAwsS3 {
            lastExecutedAt
            data {
              id
              bucket
              pathPrefix
              region
              accessKeyId
            }
            integrationExecutions(page: $page) {
              meta {
                totalEntries
                totalPages
                currentPage
                nextPage
                previousPage
              }
              entries {
                id
                state
                data
                results
                insertedAt
                user {
                  id
                  email
                  fullname
                  pictureUrl
                }
                version {
                  id
                  tag
                }
              }
            }
          }

          ... on ProjectIntegrationAzureStorageContainer {
            lastExecutedAt
            data {
              id
              sasBaseUrl
            }
            integrationExecutions(page: $page) {
              meta {
                totalEntries
                totalPages
                currentPage
                nextPage
                previousPage
              }
              entries {
                id
                state
                data
                results
                insertedAt
                user {
                  id
                  email
                  fullname
                  pictureUrl
                }
                version {
                  id
                  tag
                }
              }
            }
          }
        }
      }
    }
  }
`;
