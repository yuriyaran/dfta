import { click, fillIn, find, render } from '@ember/test-helpers';
import { setupRenderingTest } from 'dealfront/tests/helpers';
import { hbs } from 'ember-cli-htmlbars';
import { module, test } from 'qunit';

module('Integration | Component | github-form', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(async function () {
    this.set('onSubmit', () => {});
    this.set('updateOrgName', () => {});
    this.set('orgsLoading', false);
    this.set('orgName', '');

    await render(
      hbs`<GithubForm
        @orgsLoading={{this.orgsLoading}}
        @orgName={{this.orgName}}
        @updateOrgName={{this.updateOrgName}}
        @onSubmit={{this.onSubmit}}
      />`,
    );
  });

  test('it renders', async function (assert) {
    assert
      .dom('[data-test-input="access-token"]')
      .hasValue()
      .hasAttribute('readonly', 'true');

    assert.dom('[data-test-input="gh-org-name"]').hasNoValue();
  });

  test('input validation handling', async function (assert) {
    await click('[data-test-submit-button]');

    const input = find('[data-test-input="gh-org-name"]') as HTMLInputElement;
    assert.notOk(input.checkValidity());

    const invalidValues = ['   ', '-a2-', 'b.rt'];
    for (const value of invalidValues) {
      await fillIn(input, value);
      assert.notOk(input.checkValidity());
    }
  });

  test('handles submit', async function (assert) {
    let submittedValue: string | undefined;
    this.set('updateOrgName', (value: string) => (submittedValue = value));
    this.set('onSubmit', () => {
      this.set('orgsLoading', true); // simulates loading state
    });

    await fillIn('[data-test-input="gh-org-name"]', 'github');
    await click('[data-test-submit-button]');

    assert.equal(submittedValue, 'github', 'submitted value is correct');
    assert.dom('[data-test-submit-button]').hasText('...Loading...');
  });
});
