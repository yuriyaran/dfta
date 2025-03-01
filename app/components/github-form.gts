import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { action } from '@ember/object';
import ENV from 'dealfront/config/environment';

export interface GithubFormSignature {
  // The arguments accepted by the component
  Args: {
    orgsLoading: boolean;
    orgName: string;
    updateOrgName: (name: string) => void;
    onSubmit: () => void;
  };
  // The element to which `...attributes` is applied in the component template
  Element: HTMLFormElement;
}

export default class GithubForm extends Component<GithubFormSignature> {
  accessToken: string = ENV.GITHUB_PAT_CLASSIC;

  @action
  updateOrgName(event: Event): void {
    const { value } = event.target as HTMLInputElement;
    if (value) this.args.updateOrgName(value);
  }

  @action
  handleSubmit(event: Event): void {
    event.preventDefault();
    this.args.onSubmit();
  }

  <template>
    <form class="github-form" {{on "submit" this.handleSubmit}} ...attributes>
      <div class="form-row">
        <label for="access-token">GitHub Personal Access Token (Classic)</label>
        <input
          id="access-token"
          data-test-input="access-token"
          value={{this.accessToken}}
          readonly="true"
        />
      </div>
      <div class="form-row">
        <label for="gh-org-name">GitHub Organization Name</label>
        <input
          id="gh-org-name"
          data-test-input="gh-org-name"
          placeholder="Enter your GitHub organization name"
          pattern="[A-Za-z0-9]+(-[A-Za-z0-9]+)*"
          required
          autocomplete="off"
          {{on "change" this.updateOrgName}}
        />
      </div>
      <div class="form-row">
        <button data-test-submit-button type="submit" disabled={{@orgsLoading}}>
          {{if @orgsLoading "⏳ Loading..." "Get Your Repos"}}
        </button>
      </div>
    </form>
  </template>
}
