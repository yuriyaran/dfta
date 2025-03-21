import Component from '@glimmer/component';
import { tracked } from 'tracked-built-ins';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { type FilterArgs } from 'dealfront/components/repos/types';
import { type Repository } from 'dealfront/controllers/application';
import ReposFilter from './repos/filter';
import ResetFilters from 'dealfront/modifiers/reset-filters';

interface ReposTableSignature {
  // The arguments accepted by the component
  Args: {
    repos: Repository[];
    org: string;
    orgsLoading: boolean;
    branchesLoading: boolean;
    onRowSelect: (url: string) => Promise<string>;
  };
  // The element to which `...attributes` is applied in the component template
  Element: HTMLTableElement;
}

export default class ReposTable extends Component<ReposTableSignature> {
  @tracked selectedLanguage = 'All';
  @tracked selectedPrivacy = 'All';

  reposPrivacy = ['All', 'Private', 'Public'];
  get reposLangs(): string[] {
    const langs = this.args.repos.map(
      ({ language }: Repository) =>
        language ??
        String(language) /* converts null to a string value 'null' */,
    );

    return ['All', ...new Set(langs)];
  }

  get showAllRepos(): boolean {
    return this.selectedLanguage === 'All' && this.selectedPrivacy === 'All';
  }

  get showFilters(): boolean {
    return (
      (!this.showAllRepos || this.filteredRepos.length) &&
      !this.args.orgsLoading
    );
  }

  get filteredRepos(): Repository[] {
    if (this.showAllRepos) return this.args.repos;

    return this.args.repos.filter(
      ({ language, private: isPrivate }: Repository) => {
        const languageMatches =
          this.selectedLanguage === 'All' ||
          (language?.toLowerCase() ?? String(language)) ===
            this.selectedLanguage.toLowerCase();

        const privacyMatches =
          this.selectedPrivacy === 'All' ||
          isPrivate === (this.selectedPrivacy.toLowerCase() === 'private');

        return languageMatches && privacyMatches;
      },
    );
  }

  @action
  setFilter({ language, privacy }: FilterArgs): void {
    if (language) this.selectedLanguage = language;
    if (privacy) this.selectedPrivacy = privacy;
  }

  @action
  toggleBranchesRow(repo: Repository, event: Event): void {
    if (this.args.branchesLoading) return;

    const existingRow: HTMLTableElement = document.querySelector(
      `[data-test-row-branches="${repo.name}"]`,
    );
    if (existingRow) {
      existingRow.classList.toggle('hidden');
    } else {
      const row = this.createBranchRow(repo.name);
      const target = event.target as HTMLTableElement;
      target.parentElement.insertAdjacentElement('afterend', row);
      this.populateRow(row, repo.url);
    }
  }

  createBranchRow = (repoName: string): HTMLTableElement => {
    const branchesRow: HTMLTableElement = document.createElement('tr');
    branchesRow.classList.add('branch-row');
    branchesRow.dataset.testRowBranches = repoName;
    branchesRow.innerHTML = `<td class="df-cell" colspan="4">⏳ Loading...</td>`;

    return branchesRow;
  };

  populateRow = async (row: HTMLTableElement, url: string): void => {
    const branches = await this.args.onRowSelect(url);
    row.innerHTML = branches
      ? `<td class="df-cell" colspan="4"><p class="branch-paragraph">${branches}</p></td>`
      : `<td class="df-cell" colspan="4"><p class="branch-paragraph">No branches returned 🫗</p></td>`;
  };

  resetFilters = (): void => {
    this.selectedLanguage = 'All';
    this.selectedPrivacy = 'All';
  };

  <template>
    {{#if this.showFilters}}
      <ReposFilter
        @langs={{this.reposLangs}}
        @privacy={{this.reposPrivacy}}
        @selectedLanguage={{this.selectedLanguage}}
        @selectedPrivacy={{this.selectedPrivacy}}
        @onFilter={{this.setFilter}}
        data-test-filters="repositories"
      />
    {{/if}}

    {{#if @orgsLoading}}
      <p
        class="list-placeholder"
        data-test-loading="repositories"
        {{ResetFilters this.resetFilters}}
      >
        ⏳ Loading...
      </p>
    {{else if @org}}
      <h1 class="org-name" data-test-caption="org-name">{{@org}}</h1>
      <table class="df-table repositories-table" ...attributes>
        {{#if this.filteredRepos.length}}
          <thead class="df-head">
            <tr class="df-row">
              <th class="df-cell header">Name</th>
              <th class="df-cell header">URL</th>
              <th class="df-cell header">Language</th>
              <th class="df-cell header">Private</th>
            </tr>
          </thead>
        {{/if}}
        <tbody>
          {{#each this.filteredRepos as |repo|}}
            {{! template-lint-disable no-invalid-interactive }}
            <tr
              class="df-row repo-row"
              data-test-row-repo={{repo.name}}
              {{on "click" (fn this.toggleBranchesRow repo)}}
            >
              <td
                class="df-cell"
                data-test-cell-name={{repo.name}}
                data-label="Name"
              >{{repo.name}}</td>
              <td class="df-cell" data-label="URL">
                <a
                  href={{repo.html_url}}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  {{repo.html_url}}
                </a>
              </td>
              <td class="df-cell" data-label="Language">
                {{if repo.language repo.language "null"}}
              </td>
              <td class="df-cell" data-label="Private">{{repo.private}}</td>
            </tr>
          {{else}}
            <tr class="df-row">
              <td class="df-cell" colspan="4">
                <p class="list-placeholder" data-test-list="filtered-empty">
                  {{#if this.showAllRepos}}
                    0️⃣&nbsp;
                    {{@org}}
                    has no repositories. 0️⃣
                  {{else}}
                    🧻 Jeez! You took too far with the filters! None of the
                    repositories matches your criteria. 🧻
                  {{/if}}
                </p>
              </td>
            </tr>
          {{/each}}
        </tbody>
      </table>
    {{else}}
      <p class="list-placeholder" data-test-list="empty">
        ⬆️ Enter a GitHub organization name above to explore its repositories.
        ⬆️
      </p>
    {{/if}}
  </template>
}
