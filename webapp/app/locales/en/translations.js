export default {
  addon: {
    channel: {
      handle_in: {
        create_collaborator:
          '{{user}} invited {{collaboratorEmail}} on the project',
        create_comment:
          '{{user}} commented on {{translationKey}}: {{commentText}}',
        sync: '{{user}} synced a file: {{documentPath}}'
      }
    }
  },
  components: {
    jipt: {
      back_to_translations: {
        back: 'Back'
      },
      translations_filtered_title: {
        title_count: {
          one: 'This element contains 1 string',
          other: 'This element contains {{count}} strings'
        }
      }
    },
    documents_add_button: {
      link: 'Synchronize a new file'
    },
    versions_add_button: {
      link: 'Create new version'
    },
    revision_selector: {
      languages_count: {
        one: '1 other language',
        other: '{{count}} other languages'
      },
      master: 'master'
    },
    translation_comments_subscriptions: {
      title: 'Notify on new messages'
    },
    google_login_form: {
      title: 'Google authentication',
      subtitle:
        'We use your Google account for authentication only, we will not spam you or access any of your sensitive informations.',
      login_button: 'Login with Google'
    },
    dummy_login_form: {
      title: 'Fake authentication',
      warning: 'Looks like you don’t have a valid Google API setup :(',
      subtitle:
        'You can use any email to be automatically logged in the platform. Be sure that the API you’re connecting to is in dev mode and not built for production. <strong>The fake login setup is disabled in production.</strong>',
      login_button: 'Login with any email'
    },
    activity_item: {
      rollbacked: 'Rollbacked',
      details: 'Details',
      empty_text: 'Empty text'
    },
    application_footer: {
      accent_bot: 'Accent CLI',
      text: 'Made with computers by'
    },
    collaborator_create_form: {
      create_button: 'Add collaborator',
      email_placeholder: 'Add a collaborator by email…'
    },
    commit_file: {
      cancel_button: 'Cancel',
      file_input_button: 'Choose a file',
      commit_error: 'An error occured while uploading the file',
      document_format: 'Format of the file',
      document_path: 'Name of the file',
      language: 'Language',
      commit_type: 'Mode',
      file_source: 'Document path',
      merge_button: 'Add translations',
      pattern_help:
        'You need to specify the pattern of the files included in the zip that will be imported, eg: **/*.strings',
      new_document_warning: 'The changes will create a new file.',
      existing_document_warning:
        'The changes will be applied to the already existing file.',
      peek_button: 'Preview sync',
      peek_error: 'An error occured while previewing the file',
      peek_help:
        'You can preview the effect of your file(s) on the project. This action won’t do anything to your project, you’re safe to preview whatever you want ;)',
      sync_button: 'Sync',
      upload_help:
        'After choosing a file you will be able to preview the changes on your project',
      upload_title: 'Select a file',
      tips: {
        formats: {
          title: 'Supported formats',
          text:
            'From Ruby on Rails YAML to Java Properties XML, many formats are supported by Accent. <a href="https://www.accent.reviews/guides/formats.html">See all formats →</a>'
        },
        mix: {
          title: 'Mix and match',
          text:
            'You can upload .strings format on Android XML file and vice-versa. This makes it easy to share localization files between platforms.'
        },
        cli: {
          title: 'Have many files to upload?',
          text:
            'Use accent-cli to upload many files at once and write back the changes locally. <a href="https://github.com/mirego/accent-cli">See how to install →</a>'
        }
      }
    },
    conflict_item: {
      correct_button_text: 'Mark as reviewed',
      correct_error_text: 'Failed to correct the conflict. Try again later.',
      no_previous_text: 'No previous text',
      same_text: 'Same previous text',
      uncorrect_button_text: 'Uncorrect',
      uncorrect_error_text: 'Failed to uncorrect the conflict. Try again later.'
    },
    conflicts_actions: {
      reload_button: 'Reload'
    },
    conflicts_filters: {
      total_entries_count: {
        one: '1 string to review',
        other: '{{count}} strings to review',
        zero: 'No strings to review'
      },
      reference_default_option_text: 'No reference language',
      document_default_option_text: 'All documents',
      input_placeholder_text: 'Search for a string'
    },
    conflicts_items: {
      correct_all_button: 'Mark all strings as reviewed for this language',
      fullscreen: 'Fullscreen',
      no_translations: 'No strings to review for: {{query}}',
      review_completed: 'All reviewed!'
    },
    dashboard_master_revision: {
      features: {
        documents: {
          text:
            'Manage your files, view a preview of the exported content, and finally, save your file on your machine.',
          title: 'Files'
        },
        export: {
          text: 'Save all strings in a file to include it in your project.',
          title: 'Export'
        },
        review: {
          text:
            'Mark strings as reviewed, correct them while seeing a text diff of the previous content. You can even see the text of another language for the matching string.',
          title: 'Review'
        },
        sync: {
          text:
            'Upload your localization files to add, remove and update strings.',
          title: 'Sync'
        },
        translations: {
          text:
            'Search and filter your strings to quickly navigate in your project and see which strings are in review, commented on or recently updated.',
          title: 'All strings'
        }
      },
      keys: 'strings',
      last_synced_at_label: 'Last sync:',
      master_language_label: 'Master language is:',
      never_synced: 'Sync the project for the first time',
      reviewed: 'reviewed'
    },
    dashboard_navigation: {
      collaborators_link_title: 'Collaborators',
      edit_link_title: 'Edit',
      overview_link_title: 'Overview'
    },
    dashboard_revisions: {
      manage_languages_link_title: 'Manage languages',
      new_language_link_title: 'New language',
      new_language_link_text:
        'With another language, you can keep track of translation based on the master language.',
      view_more_activities: 'View more activities →',
      title: 'Dashboard',
      master: 'Master language',
      slaves: 'Translations',
      sync: 'Sync',
      strings: 'strings',
      all_reviewed: 'All reviewed!',
      reviewed: 'reviewed',
      activities_title: 'Latest activities',
      item: {
        correct_all_button: 'Mark all strings as reviewed',
        uncorrect_all_button: 'Put all strings back in review'
      }
    },
    date_tag: {
      formatted_date_time_format: 'YYYY-MM-DDTHH:mm:ss',
      humanized_date_title_format: 'MMMM Do YYYY, HH:mm:ss'
    },
    versions_list: {
      export: 'Export',
      update: 'Edit'
    },
    documents_list: {
      format: 'Format',
      review: 'In review',
      total: 'Total',
      sync: 'Sync',
      merge: 'Add translations',
      export: 'Export',
      export_jipt: 'Just in place translations',
      no_strings: 'No strings',
      total_strings_count: {
        zero: 'No strings',
        one: '1 string',
        other: '{{count}} strings'
      },
      language_strings_count: {
        zero: '',
        one: '1 string per language',
        other: '{{count}} strings per language'
      },
      delete_document: 'Remove this file'
    },
    error_section: {
      logout: 'Logout',
      or: 'or',
      return: 'return to home'
    },
    project_activity: {
      stats_label: 'Activities performed:',
      overview_label: 'Overview:',
      review_label: 'Was reviewed?',
      reviewed_yes: 'Yes',
      reviewed_no: 'No',
      last_synced_text_label: 'Last synced text:',
      text_before_action_label: 'Text before the activity:',
      new_text_label: 'New text:',
      empty_value: 'Empty text',
      text_differences_label: 'Differences:',
      rollback_operation_label: 'Rollbacked by this activity:',
      rollbacked_operation_label: 'Rollbacked this activity:',
      batch_operation_label: 'Generated by this activity:',
      operations_label: 'Generated these activities:',
      rollbacked_label: 'Rollbacked',
      file_label: 'File:',
      details_label: 'Details:',
      explanation_label: 'Why did this happen?',
      rollback_confirm:
        'Are you sure you want to rollback this activity? You cannot undo a rollback.',
      rollback: 'Rollback',
      stats_label_text: 'Activities performed:',
      stats_text: {
        merge_on_corrected: 'Translated string',
        add_to_version: 'Versioned strings',
        version_new: 'Versioned strings',
        merge_on_proposed: 'Translated string',
        merge_on_proposed_force: 'Translated (force) string',
        merge_on_corrected_force: 'Translated (force) string',
        conflict_on_proposed: 'New conflict',
        conflict_on_corrected: 'New conflict',
        conflict_on_slave: 'New conflict reflected in another language',
        correct_conflict: 'Strings marked as reviewed',
        uncorrect_conflict: 'Strings marked as not reviewed',
        update: 'Update string',
        new: 'New string',
        renew: 'Renew string',
        remove: 'Delete string',
        update_proposed: 'Update synced text reference'
      },
      action_explanation: {
        add_to_version:
          'When a user creates a version, the string is copied as a versioned string. The string will remain untouched by the "main" version',
        version_new:
          'When a user creates a version, the string is copied as a versioned string. The string will remain untouched by the "main" version',
        create_version:
          'When a user freeze the state of all strings to tag it with a version. Used to maintain multiple versions of the same app in parallel.',
        conflict_on_corrected:
          'When the uploaded text is different than the last synced text and the last synced text is different than the current text. This happens if the text has been touched by a user in Accent. It is uselful to identify a conflict that is caused by a difference in a sync and the modified version in Accent.',
        conflict_on_proposed:
          'When the uploaded text is different than the last uploaded text and the last synced text is equal to the current text. This happens if the text has not been touched by a user in Accent. It is uselful to identify a conflict that is only caused by a sync and not a human intervention.',
        conflict_on_slave:
          'When the activity "conflict on proposed" or "conflict on corrected" happens on a string, the matching keys in other languages apply this activity. The goal of this activity is to flag a change of meaning in the master language in the translations. The string will be flagged as "in review"',
        correct_all: 'When all the strings are manually marked as reviewed.',
        correct_conflict: 'When a string is manually marked as reviewed.',
        batch_correct_conflict:
          'When multiple strings were marked as reviewed in a short lapse of time.',
        document_delete: 'When a file has been deleted.',
        merge:
          'When strings are updated with new translations from a file upload. This applies the same logic as the sync activity but without removing strings.',
        merge_on_corrected:
          'When the uploaded text is different than the last synced text and the last synced text is different than the current text. This happens if the text has been touched by a user in Accent. It is uselful to identify a conflict that is caused by a difference in the sync upload and the modified version in Accent.',
        merge_on_proposed:
          'When the uploaded text is different than the last synced text and the last synced text is equal to the current text. This happens if the text has not been touched by a user in Accent. It is uselful to identify a conflict that is only caused by the sync upload and not a human intervention.',
        merge_on_corrected_force:
          'When the uploaded text is different than the last synced text and the last synced text is different than the current text. This happens if the text has been touched by a user in Accent. It is uselful to identify a conflict that is caused by a difference in the sync upload and the modified version in Accent.',
        merge_on_proposed_force:
          'When the uploaded text is different than the last synced text and the last synced text is equal to the current text. This happens if the text has not been touched by a user in Accent. It is uselful to identify a conflict that is only caused by the sync upload and not a human intervention.',
        remove: 'When the synced file does not contain the key.',
        new:
          'When the synced file contains a key that is not present in the file.',
        renew:
          'When the synced file contains a key that was previously removed.',
        new_slave: 'When a new language is added to the project.',
        rollback: 'When a user manually rollback an activity.',
        sync: 'When a document is synced with a file.',
        uncorrect_all: 'When all the strings are manually put back in review.',
        uncorrect_conflict: 'When the string is manually put back in review.',
        batch_update: 'When multiple strings are manually updated by someone.',
        update: 'When the string is manually updated by someone.',
        update_proposed:
          'When the synced text is the same as the current text but different than the last synced text. The only thing this activity does is make sure that the reference of the last synced text is updated. This does not affect the string’s text.'
      },
      action_text: {
        add_to_version: 'froze the string in a version',
        version_new: 'added the string to a version',
        create_version: 'created a new version',
        conflict_on_corrected: '’s sync activity created a conflict',
        conflict_on_proposed: '’s sync activity created a conflict',
        conflict_on_slave:
          '’s sync activity created a conflict reflected in another language',
        correct_conflict: 'marked the string as reviewed',
        batch_correct_conflict: 'marked multiple strings as reviewed',
        merge_on_corrected: '’s translations additions modified the string',
        merge_on_proposed: '’s translations additions modified the string',
        merge_on_corrected_force:
          '’s translations additions (force) modified the string:',
        merge_on_proposed_force:
          '’s translations additions (force) modified the string:',
        new: 'added a string',
        renew: 're-added a string',
        remove: 'removed a string',
        rollback: 'rollbacked an operation',
        uncorrect_conflict: 'put a string back to review',
        update: 'updated a string',
        batch_update: 'updated multiple strings',
        update_proposed: 'updated an uploaded text reference',
        sync: 'synced a file',
        new_slave: 'added a new language',
        uncorrect_all: 'put all strings back to review',
        correct_all: 'marked all strings as reviewed',
        document_delete: 'deleted a file',
        merge: 'added translations for some strings'
      },
      label_text: {
        conflict_on_corrected: 'The text has been moved to review and is now:',
        conflict_on_proposed: 'The text is still in review and is now:',
        conflict_on_slave: 'The text has been moved to review and is now:'
      }
    },
    project_settings: {
      back_link: {
        title: '← Back to settings'
      },
      links_list: {
        collaborators: 'Collaborators',
        badges: 'Badges',
        api_token: 'API Token',
        service_integrations: 'Service & integrations',
        manage_languages: 'Manage languages',
        jipt: 'Just In Place Translations'
      },
      delete_form: {
        title: 'Danger zone',
        delete_project_title: 'Delete this project',
        delete_project_text:
          'Once you delete a project, there is no going back.',
        delete_project_button: 'Delete this project',
        delete_project_confirm:
          'Are you sure you want to delete this project? This action cannot be undone.'
      },
      form: {
        update_button: 'Update project',
        lock_file_operations: {
          text_1:
            'When the file operations are locked, syncing and adding translations will be disabled.',
          remove_lock_button: 'Unlock file operations',
          add_lock_button: 'Lock file operations'
        }
      },
      jipt: {
        title: 'Just In Place Translations',
        integration_help:
          'This steps will walk you throught the setup you need to have in your project to translate your strings in your browser, inside your project.',
        script_title: 'Add the script at the root of your app',
        add_language_title: 'Add the pseudo language to your project',
        add_language_image_1:
          'Here is a language like you already have in your project:',
        add_language_image_2:
          'Here is the pseudo language named "accent" that act as a normal translsation in your project:',
        use_language_title: 'Use the pseudo language',
        pseudo_language_text:
          'The Accent script parses the DOM for strings that match the Just In Place Translations export. Go in the "Files" section to export the file or use the CLI to add the pseudo language to your project.',
        use_language_text:
          'By switching to the Accent language using your favorite framework i18n tool, the page will display the strings in the pseudo language files and the Accent script will replace those by the strings in Accent. It will also bind click event on the elements so that you can select strings directly in your app and edit them via Accent.'
      },
      api_token: {
        title: 'API token',
        text_1:
          'With this token, you can make authentified calls to Accent’s API. All operations will be flagged as "made by the API client".',
        text_2:
          'Typically, this is used to sync and add translations the localization files in a deploy script.'
      },
      badges: {
        title: 'Badges',
        text:
          'Can be embedded in markdown files or displayed on a web page to show public stats for a given project.',
        percentage_reviewed: 'Percentage reviewed:'
      },
      collaborators: {
        admin_text:
          'Can add languages, update the project and add/remove collaborators.',
        developer_text:
          'Can make file operations: Sync, add translations and preview those operations in the UI.',
        owner_text:
          'With the same roles as the admin, the owners are people who the project belongs to.',
        reviewer_text:
          'Can do every tasks except those listed in the above roles. Review, update strings, comments, etc.',
        title: 'Collaborators'
      },
      collaborators_item: {
        by: 'by',
        cancel_save_role: 'Cancel',
        delete_button: 'Remove collaborator',
        edit_role: 'Edit role',
        joined: 'Join the project',
        invited: 'Invited',
        save_role: 'Save role',
        uninvite_button: 'Remove invitation'
      },
      integrations: {
        title: 'Service & integrations',
        help:
          'Services are pre-built integrations that perform certain actions when events occur on Accent.',
        save: 'Save',
        edit: 'Edit',
        delete: 'Delete',
        events: {
          title: 'Which events would you like to trigger this webhook?',
          options: {
            sync: 'Sync'
          }
        }
      }
    },
    project_activities_filter: {
      actions: {
        conflict_on_corrected: 'Conflict on corrected',
        conflict_on_proposed: 'Conflict on proposed',
        conflict_on_slave: 'Conflict on slave',
        correct_all: 'Correct all',
        correct_conflict: 'Correct conflict',
        batch_correct_conflict: 'Correct conflicts',
        document_delete: 'File delete',
        new: 'New',
        renew: 'Renew',
        new_comment: 'New comment',
        remove: 'Remove',
        rollback: 'Rollback',
        merge: 'Add translations',
        sync: 'Sync',
        uncorrect_all: 'Uncorrect all',
        uncorrect_conflict: 'Uncorrect conflict',
        update: 'Update string',
        batch_update: 'Update strings'
      },
      actions_default_option_text: 'All activities',
      collaborators_default_option_text: 'All collaborators',
      only_important_activities_text: 'Only important activities'
    },
    project_activities_list: {
      title: 'Activities',
      empty_activities_text: 'No activities found'
    },
    project_activities_list_item: {
      stats_label_text: 'Activities performed:',
      stats_text: {
        add_to_version: 'Versioned strings',
        version_new: 'Versioned strings',
        merge_on_corrected: 'Translated string',
        merge_on_proposed: 'Translated string',
        merge_on_proposed_force: 'Translated (force) string',
        merge_on_corrected_force: 'Translated (force) string',
        conflict_on_proposed: 'New conflict',
        conflict_on_corrected: 'New conflict',
        conflict_on_slave: 'New conflict reflected in another language',
        correct_conflict: 'Strings marked as reviewed',
        uncorrect_conflict: 'Strings marked as not reviewed',
        update: 'Updated string',
        new: 'New string',
        renew: 'Renew string',
        remove: 'Delete string',
        update_proposed: 'Update uploaded text reference:'
      },
      action_text: {
        add_to_version: 'froze the string in a version:',
        version_new: 'added the string to the version:',
        create_version: 'created a new version:',
        remove: 'removed the string:',
        renew: 'added the previously removed string:',
        new: 'added the string:',
        conflict_on_corrected: 'last sync activity created a conflict:',
        conflict_on_proposed: 'last sync activity created a conflict:',
        conflict_on_slave:
          'last sync activity created a conflict reflected in another language:',
        correct_all: 'marked all strings as reviewed',
        correct_conflict: 'marked a string as reviewed:',
        batch_correct_conflict: 'marked multiple strings as reviewed:',
        document_delete: 'deleted a file:',
        merge: 'added translations for some strings',
        merge_on_corrected: 'last translations additions modified a string:',
        merge_on_proposed: 'last translations additions modified a string:',
        merge_on_corrected_force:
          'last translations additions (force) modified a string:',
        merge_on_proposed_force:
          'last translations additions (force) modified a string:',
        new_comment: 'added a new comment:',
        new_slave: 'added a new language',
        rollback: 'rollbacked an operation:',
        sync: 'synced a file:',
        uncorrect_all: 'put all strings back to review',
        uncorrect_conflict: 'put a string back to review:',
        update: 'updated the string:',
        batch_update: 'updated multiple strings:',
        update_proposed: 'updated the uploaded text reference:'
      },
      label_text: {
        conflict_on_corrected: 'The text has been moved to review and is now:',
        conflict_on_proposed: 'The text is still in review and is now:',
        conflict_on_slave: 'The text has been moved to review and is now:'
      }
    },
    project_comments_list: {
      no_comments: 'No comments on any strings yet',
      title: 'Conversation'
    },
    project_create_form: {
      title: 'New project',
      error: 'Invalid project',
      cancel_button: 'Cancel',
      language_label: 'Master language:',
      language_search_placeholder: 'Search languages…',
      name_label: 'Name:',
      save_button: 'Create'
    },
    version_create_form: {
      title: 'New version',
      text:
        'Creating a version makes a snapshot of all the active strings (reviewed or not) to be viewable with the certainty that it will remain untouched. This can be useful when maintaining multiple version of the same app.',
      error: 'Invalid version',
      cancel_button: 'Cancel',
      name_label: 'Name:',
      tag_label: 'Tag:',
      save_button: 'Create'
    },
    version_update_form: {
      title: 'Update version',
      error: 'Invalid version',
      cancel_button: 'Cancel',
      name_label: 'Name:',
      tag_label: 'Tag:',
      save_button: 'Update'
    },
    project_file_operations: {
      sync: 'Sync',
      merge: 'Add translations',
      export: 'Export',
      document_format: 'Format',
      preview_title: 'Preview',
      preview_text: 'You must choose a file, then click on the Preview button.',
      export_jipt: 'Just In Place Translation'
    },
    project_navigation: {
      activities_link_title: 'Activities',
      conversation_link_title: 'Conversation',
      translations_link_title: 'All strings',
      conflicts_link_title: 'Review',
      dashboard_link_title: 'Dashboard',
      settings_link_title: 'Settings',
      sync_link_title: 'Files',
      versions_link_title: 'Versions'
    },
    project_manage_languages: {
      create_error: 'Language can not be added right now. Try again later.',
      conflicts_explain_title: 'On conflicts',
      conflicts_explain_text:
        'Every string addition or deletion will be reflected in the language. When a text changes in the master revision, the string in the language will be marked as in review.',
      sync_explain_title: 'On sync',
      sync_explain_text:
        'The master language will be the default source when syncing a file. The other languages are never "synced", they just follow the master language.',
      add_translations_explain_title: 'On add translations',
      add_translations_explain_text:
        'Every languages can have strings "merged" into it by adding translations. Conflict resolution will work the same but will never add or remove strings.',
      main_text:
        'You can add a new language that will follow the master language.',
      title: 'Manage languages'
    },
    projects_filters: {
      searching_for: 'Searching for:',
      input_placeholder_text: 'Search for a project',
      new_project: 'New project'
    },
    projects_list: {
      last_synced_at_label: 'Last sync:',
      last_activity_at_label: 'Last activity:',
      never_synced: 'Project was never synced',
      no_projects: 'You have no projects yet',
      no_projects_query: 'No projects found for: {{query}}',
      maybe_create_one: 'Create your first project here →'
    },
    related_translations_list: {
      comments_label: {
        one: '1 comment',
        other: '{{count}} comments',
        zero: 'No comments'
      },
      conflicted_label: 'in review',
      last_updated_label: 'Last updated: ',
      new_language_link: 'New language',
      no_related_translations:
        'No translations yet. You need to add another language to your project.'
    },
    removed_translation_edit: {
      cant_edit: 'This string can’t be edited because it has been removed.'
    },
    project_manage_languages_create_form: {
      language_search_placeholder: 'Search languages…',
      save_button: 'Add language'
    },
    project_manage_languages_overview: {
      list_languages: 'Here is a list of the project’s languages:',
      revision_inserted_at_label: 'Created',
      master_badge: 'master',
      delete_revision_confirm:
        'Are you sure you want to remove this language from your project? This action cannot be rollbacked.',
      delete_revision_button: 'Remove this language',
      promote_revision_master_confirm:
        'Are you sure you want to use this language as the master language from your project?',
      promote_revision_master_button: 'Use as master'
    },
    revision_export_options: {
      default_format: 'Default format',
      orders: {
        az: 'Alphabetical order',
        original: 'Original order'
      },
      save_button: 'Export'
    },
    revision_navigation: {
      documents_link_title: 'Files',
      merge_link_title: 'Add translations',
      review_link_title: 'Review',
      translations_link_title: 'All strings'
    },
    time_ago_in_words_tag: {
      formatted_date_time_format: 'YYYY-MM-DDTHH:mm:ss',
      humanized_date_title_format: 'dddd, MMMM Do YYYY, H:mm a'
    },
    translation_activities_list_item: {
      action_text: {
        add_to_version: 'froze the string in a version:',
        version_new: 'added the string to the version:',
        create_version: 'created a new version',
        conflict_on_corrected: 'last sync activity created a conflict',
        conflict_on_proposed: 'last sync activity created a conflict',
        conflict_on_slave:
          'last sync activity created a conflict reflected in another language',
        correct_conflict: 'marked the string as reviewed',
        merge_on_corrected: 'last translations additions modified the string',
        merge_on_proposed: 'last translations additions modified the string',
        merge_on_corrected_force:
          'last translations additions (force) modified the string:',
        merge_on_proposed_force:
          'last translations additions (force) modified the string:',
        new: 'added the string',
        renew: 're-added the string',
        new_comment: 'added a new comment:',
        remove: 'removed the string',
        rollback: 'rollbacked an operation',
        uncorrect_conflict: 'put the string back to review',
        update: 'updated the text',
        update_proposed: 'updated the uploaded text reference'
      },
      label_text: {
        conflict_on_corrected: 'The text has been moved to review and is now:',
        conflict_on_proposed: 'The text is still in review and is now:',
        conflict_on_slave: 'The text has been moved to review and is now:'
      }
    },
    translation_comment_form: {
      comment_button: 'Comment',
      comment_placeholder: 'Leave a comment…',
      submit_error:
        'Your comment submission was not successful, try again later.'
    },
    translation_comments_list: {
      no_comments: 'No comments'
    },
    translation_edit: {
      source_translation: 'See latest version of the string',
      correct_button: 'Update and mark as reviewed',
      previous_text: 'Previous text:',
      uncorrect_button: 'Put back to review',
      uneditable:
        'The text is not editable because it has been marked as reviewed',
      update_text: 'Update text',
      last_updated_label: 'Last updated:',
      form: {
        true_option: 'true',
        false_option: 'false',
        integer_type_notice: 'The text has been set with an integer value.',
        float_type_notice: 'The text has been set with a float value.',
        empty_type_notice: 'The text has been set to an empty string',
        empty_type_placeholder: 'Empty text',
        null_type_notice: 'The text has been set to null',
        placeholders: {
          title: 'Placeholders',
          text:
            'These custom expressions mark special strings that will be replaced by dynamic values. You do not have to review or translate them.'
        }
      }
    },
    translation_navigation: {
      activities_link_title: 'Activities',
      comments_link_title: {
        one: 'Conversation (1)',
        other: 'Conversation ({{count}})',
        zero: 'Conversation'
      },
      edit_link_title: 'Edit',
      merge_link_title: 'Add translations',
      related_translations_link_title: 'Translations'
    },
    translation_splash_title: {
      plural_label: 'plural',
      conflicted_label: 'in review',
      removed_label: 'This string was removed {{removedAt}}'
    },
    translations_filter: {
      input_placeholder_text: 'Search for a string',
      documents_label: 'Filter from document:',
      document_default_option_text: 'All documents',
      version_default_option_text: 'Latest version',
      total_entries_count: {
        one: '1 string found',
        other: '{{count}} strings found',
        zero: 'No strings found'
      }
    },
    translations_list: {
      comments_count: {
        one: '1 comment',
        other: '{{count}} comments',
        zero: 'No comments'
      },
      empty_text: 'Empty text',
      in_review_label: 'in review',
      last_updated_label: 'Last updated: ',
      maybe_sync_before: 'Maybe try to',
      maybe_sync_link: 'sync some files →',
      no_translations: 'Looks like no strings were added for your project.',
      no_translations_query: 'No strings found for: {{query}}'
    },
    welcome_project: {
      welcome: 'Welcome!',
      welcome_translations:
        'Bienvenue Bienvenido 환영 欢迎 тавтай морилно уу Welkom Tervetuloa',
      first_step: 'First steps',
      after_steps: 'After this, you will be able to',
      sync_file: 'Sync a new file',
      sync_file_text: 'Add strings from multiple file formats to review them',
      manage_languages: 'Add languages',
      manage_languages_text:
        'Target languages follow your master language strings and conflicts',
      add_collaborator: 'Add collaborator',
      add_collaborator_text: 'Translators, developers, etc.',
      api_token: 'Get your API Token',
      api_token_text: 'Interact with the API from your project',
      start_review: 'Start to review and translate',
      export: 'Export the corrected file',
      help: 'Help?'
    }
  },
  general: {
    application_name: 'Accent',
    logout_button: 'Logout',
    roles: {
      ADMIN: 'Admin',
      DEVELOPER: 'Developer',
      OWNER: 'Owner',
      REVIEWER: 'Reviewer'
    },
    integration_services: {
      SLACK: 'Slack'
    },
    search_input_placeholder_text: 'Search for a string…'
  },
  pods: {
    login: {
      title: 'Login or signup'
    },
    error: {
      not_found: {
        status: '404',
        title: 'Not found',
        text: 'This page doesn’t exist.'
      },
      unauthorized: {
        status: '401',
        title: 'Unauthorized',
        text: 'You are not authorized to view this resource.'
      },
      internal_error: {
        status: '500',
        title: 'Internal server error',
        text: 'Something bad happened and someone has been notified.'
      }
    },
    document: {
      sync: {
        flash_messages: {
          create_error:
            'The document could not be synced with the uploaded file',
          create_success: 'The document has been synced with success'
        }
      },
      merge: {
        flash_messages: {
          create_error:
            'The document could not be uploaded with the uploaded file',
          create_success: 'The document has been uploaded with success'
        }
      },
      index: {
        flash_messages: {
          delete_error: 'The document could not be removed from the project',
          delete_success:
            'The document has been removed from the project with success'
        }
      }
    },
    new_project: {
      title: 'Create a new project'
    },
    project: {
      loading_content: 'Loading your project…',
      index: {
        loading_content: 'Fetching dashboard…',
        flash_messages: {
          revision_correct_success:
            'All strings in the language have been marked as reviewed',
          revision_correct_error:
            'An error has occured when marking all the strings in that language as reviewed',
          revision_uncorrect_success:
            'All strings in the language have been marked to be reviewed',
          revision_uncorrect_error:
            'An error has occured when marking all the strings in that language to be reviewed'
        }
      },
      activities: {
        show: {
          loading_activities: 'Fetching activities…',
          loading_content: 'Fetching activity’s details…'
        },
        flash_messages: {
          rollback_success: 'The activity has been rollbacked with success',
          rollback_error: 'The activity could not be rollbacked'
        }
      },
      translations: {
        loading_content: 'Searching the strings…'
      },
      conflicts: {
        loading_content: 'Searching the strings in review…',
        flash_messages: {
          revision_correct_success:
            'All strings in the language have been marked as reviewed',
          revision_correct_error:
            'An error has occured when marking all the strings in that language as reviewed',
          correct_error: 'The string could not be marked as reviewed',
          correct_success: 'The string as been marked as reviewed with success'
        }
      },
      edit: {
        title: 'Settings',
        loading_content: 'Fetching project’s settings…',
        flash_messages: {
          collaborator_add_error: 'The collaborator could not be added',
          collaborator_add_success:
            'The collaborator has been added with success',
          collaborator_remove_error: 'The collaborator could not be removed',
          collaborator_remove_success:
            'The collaborator has been removed with success',
          collaborator_update_error: 'The collaborator could not be updated',
          collaborator_update_success:
            'The collaborator has been updated with success',
          integration_add_error: 'The integration could not be added',
          integration_add_success:
            'The integration has been added with success',
          integration_update_error: 'The integration could not be updated',
          integration_update_success:
            'The integration has been updated with success',
          integration_remove_error: 'The integration could not be removed',
          integration_remove_success:
            'The integration has been removed with success',
          update_error: 'The project could not be updated',
          update_success: 'The project has been updated with success',
          delete_error: 'The project could not be deleted',
          delete_success: 'The project has been deleted with success'
        },
        collaborators: {
          loading_content: 'Fetching project’s collaborators…'
        },
        badges: {
          loading_content: 'Fetching project’s badges…'
        },
        api_token: {
          loading_content: 'Fetching project’s API settings…'
        },
        service_integrations: {
          loading_content: 'Fetching project’s service & integrations…'
        }
      },
      export: {
        loading_content: 'Rendering the language export'
      },
      files: {
        loading_content: 'Fetching files…',
        title: 'Files'
      },
      versions: {
        loading_content: 'Fetching versions…',
        title: 'Versions'
      },
      manage_languages: {
        loading_content: 'Fetching languages…',
        flash_messages: {
          add_revision_failure: 'The new language could not be created',
          add_revision_success:
            'The new language has been created with success',
          delete_revision_failure: 'The language could not be deleted',
          delete_revision_success: 'The language has been deleted with success',
          promote_master_revision_failure:
            'The language could not be promoted as master',
          promote_master_revision_success:
            'The language has been promoted as master with success'
        }
      }
    },
    projects: {
      loading_content: 'Fetching your projects…'
    },
    versions: {
      new: {
        flash_messages: {
          create_error: 'The version could not be created',
          create_success: 'The version has been created with success'
        }
      },
      edit: {
        flash_messages: {
          update_error: 'The version could not be updated',
          update_success: 'The version has been updated with success'
        }
      }
    },
    translation: {
      edit: {
        flash_messages: {
          correct_error: 'The string could not be marked as reviewed',
          correct_success: 'The string as been marked as reviewed with success',
          uncorrect_error: 'The string could not be put back to review',
          uncorrect_success: 'The string was put back to review with success',
          update_error: 'The string could not be updated',
          update_success: 'The string has been updated with success'
        }
      },
      comments: {
        loading_content: 'Fetching comments…'
      }
    }
  }
};
