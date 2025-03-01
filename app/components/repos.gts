import Component from '@glimmer/component';
import { tracked } from 'tracked-built-ins';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { type Repository } from 'dealfront/controllers/application';
import ReposFilter from './repos/filter';
import ResetFilters from 'dealfront/modifiers/reset-filters';

export interface ReposTableSignature {
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
      ({ language }: Repository) => language ?? String(language),
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
  setFilter({ language, privacy }): void {
    if (language) this.selectedLanguage = language;
    if (privacy) this.selectedPrivacy = privacy;
  }

  @action
  toggleBranchesRow(repo: Repository, event: Event): void {
    if (this.args.branchesLoading) return;

    const existingRow = document.querySelector(
      `[data-test-row-branches=${repo.name}]`,
    );
    if (existingRow) {
      existingRow.classList.toggle('hidden');
    } else {
      const row = this.createBranchRow(repo.name);
      this.populateRow(row, repo.url);
    }
  }

  createBranchRow = (repoName: string): HTMLTableElement => {
    const branchesRow = document.createElement('tr');
    branchesRow.classList.add('branch-row');
    branchesRow.dataset.testRowBranches = repoName;
    branchesRow.innerHTML = `<td colspan="4">⏳ Loading...</td>`;
    event.target.parentElement.insertAdjacentElement('afterend', branchesRow);

    return branchesRow;
  };

  populateRow = async (row, url): void => {
    const branches = await this.args.onRowSelect(url);
    row.innerHTML = branches
      ? `<td colspan="4"><p class="branch-paragraph"><strong>Branches:</strong> ${branches}</p></td>`
      : `<td colspan="4"><p class="branch-paragraph">No branches returned 🫗</p></td>`;
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
      <table class="repositories-table" ...attributes>
        <thead>
          <tr>
            <th>Name</th>
            <th>URL</th>
            <th>Language</th>
            <th>Private</th>
          </tr>
        </thead>
        <tbody>
          {{#each this.filteredRepos as |repo|}}
            {{! template-lint-disable no-invalid-interactive }}
            <tr
              class="repo-row"
              data-test-row-repo={{repo.name}}
              {{on "click" (fn this.toggleBranchesRow repo)}}
            >
              <td>{{repo.name}}</td>
              <td>
                <a
                  href={{repo.html_url}}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  {{repo.html_url}}
                </a>
              </td>
              <td>{{if repo.language repo.language "null"}}</td>
              <td>{{repo.private}}</td>
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
