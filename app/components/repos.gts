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
    return !this.showAllRepos || this.filteredRepos.length;
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
    const existingRow = document.querySelector(
      `[data-test-row-branches=${repo.name}]`,
    );
    if (existingRow) {
      existingRow.className =
        existingRow.className === 'hidden' ? '' : 'hidden';
    } else {
      const row = this.createBranchRow(repo.name);
      this.populateRow(row, repo.url);
    }
  }

  createBranchRow = (repoName: string): HTMLTableElement => {
    const branchesRow = document.createElement('tr');
    branchesRow.innerHTML = `<td colspan="4">...Loading...</td>`;
    branchesRow.dataset.testRowBranches = repoName;
    event.target.parentElement.insertAdjacentElement('afterend', branchesRow);

    return branchesRow;
  };

  populateRow = async (row, url): void => {
    const branches = await this.args.onRowSelect(url);
    row.innerHTML = `<td colspan="4">${branches}</td>`;
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
      <p data-test-loading="repositories" {{ResetFilters this.resetFilters}}>
        ...Loading...
      </p>
    {{else if @org}}
      <table ...attributes>
        <caption data-test-caption="org-name">{{@org}}</caption>
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
              data-test-row-repo={{repo.name}}
              {{on "click" (fn this.toggleBranchesRow repo)}}
            >
              <td>{{repo.name}}</td>
              <td>
                <a href={{repo.url}} target="_blank" rel="noopener noreferrer">
                  {{repo.url}}
                </a>
              </td>
              <td>{{if repo.language repo.language "null"}}</td>
              <td>{{repo.private}}</td>
            </tr>
          {{/each}}
        </tbody>
      </table>
    {{else}}
      <p data-test-list="empty">
        Enter a GitHub organization name above to explore its repositories.
      </p>
    {{/if}}
  </template>
}
