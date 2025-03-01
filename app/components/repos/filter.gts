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
        <p>
          <span>Language:</span>
          {{#each @langs as |lang|}}
            <label
              for="radio-lang-{{lang}}"
              data-test-label="radio-lang-{{lang}}"
              {{on "click" (fn @onFilter (hash language=lang))}}
            >
              {{lang}}
            </label>
            <input
              id="radio-lang-{{lang}}"
              type="radio"
              checked={{eq lang @selectedLanguage}}
              name="lang"
              value={{lang}}
              data-test-input="radio-lang-{{lang}}"
              hidden
            />
          {{/each}}
        </p>
        <p>
          <span>Privacy:</span>
          {{#each @privacy as |privacy|}}
            <label
              for="radio-priv-{{privacy}}"
              data-test-label="radio-priv-{{privacy}}"
              {{on "click" (fn @onFilter (hash privacy=privacy))}}
            >
              {{privacy}}
            </label>
            <input
              id="radio-priv-{{privacy}}"
              type="radio"
              checked={{eq privacy @selectedPrivacy}}
              name="privacy"
              value={{privacy}}
              data-test-input="radio-priv-{{privacy}}"
              hidden
            />
          {{/each}}
        </p>
      </fieldset>
    </form>
  </template>
}
