import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { fn, hash } from '@ember/helper';
import { eq } from 'ember-truth-helpers';

export interface ReposFilterSignature {
  // The arguments accepted by the component
  Args: {
    langs: string[];
    privacy: string[];
    onFilter: ({ language, privacy }: FilterArgs) => void;
  };
  // The element to which `...attributes` is applied in the component template
  Element: HTMLFormElement;
}

export type FilterArgs = {
  language?: string;
  privacy?: string;
};

export default class ReposFilter extends Component<ReposFilterSignature> {
  <template>
    <form ...attributes>
      <fieldset>
        <legend>Filter by</legend>
        <p class="filter-row">
          <strong>Language:</strong>
          {{#each @langs as |lang|}}
            {{#let (eq lang @selectedLanguage) as |selected|}}
              <label
                class="filter-pill {{if selected 'selected'}}"
                for="radio-lang-{{lang}}"
                data-test-label="radio-lang-{{lang}}"
                {{on "click" (fn @onFilter (hash language=lang))}}
              >
                {{lang}}
              </label>
              <input
                id="radio-lang-{{lang}}"
                type="radio"
                checked={{selected}}
                name="lang"
                value={{lang}}
                data-test-input="radio-lang-{{lang}}"
                hidden
              />
            {{/let}}
          {{/each}}
        </p>
        <p class="filter-row">
          <strong>Privacy:</strong>
          {{#each @privacy as |privacy|}}
            {{#let (eq privacy @selectedPrivacy) as |selected|}}
              <label
                class="filter-pill {{if selected 'selected'}}"
                for="radio-priv-{{privacy}}"
                data-test-label="radio-priv-{{privacy}}"
                {{on "click" (fn @onFilter (hash privacy=privacy))}}
              >
                {{privacy}}
              </label>
              <input
                id="radio-priv-{{privacy}}"
                type="radio"
                checked={{selected}}
                name="privacy"
                value={{privacy}}
                data-test-input="radio-priv-{{privacy}}"
                hidden
              />
            {{/let}}
          {{/each}}
        </p>
      </fieldset>
    </form>
  </template>
}
