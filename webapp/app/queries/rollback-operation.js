import gql from 'npm:graphql-tag';

export default gql`
  mutation OperationRollback($operationId: ID!) {
    rollbackOperation(id: $operationId) {
      operation
      errors
    }
  }
`;
