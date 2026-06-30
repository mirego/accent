import Component from '@glimmer/component';
import {action} from '@ember/object';
import DataControlText from 'accent-webapp/components/project-settings/integrations/form/data-control-text/index';
import fieldError from 'accent-webapp/helpers/field-error';
import t from 'ember-intl/helpers/t';

interface Args {
  errors: any;
  project: any;
  onChangeSas: (url: string) => void;
}

export default class AzureStorageContainer extends Component<Args> {
  <template>
    <DataControlText
      @error={{fieldError @errors 'data.azureStorageContainerSas'}}
      @label={{t
        'components.project_settings.integrations.data.azure_storage_container_sas'
      }}
      @helpLinkTitle='How to create a SAS URL?'
      @helpLinkHref='https://learn.microsoft.com/en-us/rest/api/storageservices/delegate-access-with-shared-access-signature'
      @placeholder='https://<account-name>.blob.core.windows.net/<container-name>/?<SAS-token>'
      @onChange={{this.changeSas}}
    />
  </template>
  @action
  changeSas(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeSas(target.value);
  }
}
