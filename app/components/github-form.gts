import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { action } from '@ember/object';
import ENV from 'dealfront/config/environment';

export interface GithubFormSignature {
  // The arguments accepted by the component
  Args: {
    orgsLoading: boolean;
    orgName: string;
    onSubmit: (name: string) => void;
  };
  // The element to which `...attributes` is applied in the component template
  Element: HTMLFormElement;
}

export default class GithubForm extends Component<GithubFormSignature> {
  accessToken: string = ENV.GITHUB_PAT_CLASSIC;

  @tracked orgName = this.args.orgName || '';

  @action
  updateOrgName(event: Event): void {
    const { value } = event.target as HTMLInputElement;
    if (value) this.orgName = value;
  }

  @action
  handleSubmit(event: Event): void {
    event.preventDefault();
    this.args.onSubmit(this.orgName);
  }

  <template>
    <form class="github-form" {{on "submit" this.handleSubmit}} ...attributes>
      <div class="form-row">
        <label class="df-label" for="access-token">GitHub Personal Access Token
          (Classic)</label>
        <input
          id="access-token"
          class="df-input"
          data-test-input="access-token"
          value={{this.accessToken}}
          readonly="true"
        />
      </div>
      <div class="form-row">
        <label class="df-label" for="gh-org-name">GitHub Organization Name</label>
        <input
          id="gh-org-name"
          class="df-input"
          data-test-input="gh-org-name"
          placeholder="Enter your GitHub organization name"
          pattern="[A-Za-z0-9]+(-[A-Za-z0-9]+)*"
          required
          autocomplete="off"
          {{on "change" this.updateOrgName}}
        />
      </div>
      <div class="form-row">
        <button
          class="df-button"
          data-test-submit-button
          type="submit"
          disabled={{@orgsLoading}}
        >
          {{if @orgsLoading "⏳ Loading..." "Get Your Repos"}}
        </button>
      </div>
    </form>
  </template>
}
