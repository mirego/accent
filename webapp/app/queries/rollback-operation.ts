import {gql} from '@apollo/client/core';

export default gql`
  mutation OperationRollback($operationId: ID!) {
    rollbackOperation(id: $operationId) {
      operation
      errors
    }
  }
`;
