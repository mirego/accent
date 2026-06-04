import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

interface LintEntry {
  id: string;
  checkIds: string[];
  type: string;
  value: string | null;
}

interface Args {
  lintEntries: {entries: LintEntry[]};
  permissions: Record<string, boolean>;
  onCreate: (attrs: object) => Promise<{errors: unknown}>;
  onUpdate: (attrs: object) => Promise<{errors: unknown}>;
  onDelete: (id: string) => Promise<{errors: unknown}>;
}

export default class LintEntries extends Component<Args> {
  @tracked
  editingEntry: LintEntry | null = null;

  @tracked
  creating = false;

  get showModal() {
    return this.creating || this.editingEntry !== null;
  }

  @action
  openNew() {
    this.editingEntry = null;
    this.creating = true;
  }

  @action
  openEdit(lintEntry: LintEntry) {
    this.creating = false;
    this.editingEntry = lintEntry;
  }

  @action
  closeModal() {
    this.creating = false;
    this.editingEntry = null;
  }
}
