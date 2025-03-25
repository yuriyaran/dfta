import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { task } from 'ember-concurrency';
import { modifier } from 'ember-modifier';
import DFNotificationsService from 'dealfront/services/df-notifications';
import GithubService from 'dealfront/services/github';
import {
  type Repository,
  type NotFoundResponse,
} from 'dealfront/controllers/application';
import pluralize from 'dealfront/helpers/pluralize';

interface BranchRowSignature {
  // The arguments accepted by the component
  Args: {
    repo: Repository | undefined;
    selectedRepo: string;
  };
  // The element to which `...attributes` is applied in the component template
  Element: HTMLTableElement;
}

type Branch = {
  name: string;
};

export default class BranchRow extends Component<BranchRowSignature> {
  @service declare dfNotifications: DFNotificationsService;
  @service declare github: GithubService;

  @tracked branches: Branch[] = [];

  get show(): boolean {
    return (
      this.args.selectedRepo === this.args.repo?.name ||
      this.getRepoBranches.isRunning
    );
  }

  loadBranches = modifier(async () => {
    if (!this.branches.length)
      await this.getRepoBranches.perform(this.args.repo?.url);
  });

  getRepoBranches = task({ drop: true }, async (url: string) => {
    try {
      const response = await this.github.getRepoBranches(url);

      if (response.ok) {
        this.branches = (await response.json()) as Branch[];
      } else {
        const failedResponse = (await response.json()) as NotFoundResponse;
        this.dfNotifications.notifyError(
          `${failedResponse.message}: couldn't load branches`,
        );
      }
    } catch (error: unknown) {
      if (error instanceof Error) {
        this.dfNotifications.notifyError(
          `${error.message}: couldn't load branches`,
        );
      }
      console.error(error);
    }
  });

  <template>
    {{#if this.show}}
      <tr
        class="branches-row"
        data-test-branches-row={{@repo.name}}
        {{this.loadBranches}}
      >
        <td class="df-cell" colspan="4">
          {{#if this.branches.length}}
            <h4 class="branches-heading">
              {{this.branches.length}}
              {{pluralize this.branches.length "branch"}}
            </h4>
          {{/if}}
          <p class="branches-paragraph">
            {{#if this.getRepoBranches.isRunning}}
              ⏳ Loading...
            {{else}}
              {{#each this.branches as |branch|}}
                <span class="branch-name" title={{branch.name}}>
                  {{branch.name}}
                </span>
              {{else}}
                "No branches returned 🫗"
              {{/each}}
            {{/if}}
          </p>
        </td>
      </tr>
    {{/if}}
  </template>
}
