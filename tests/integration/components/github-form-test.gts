import { click, fillIn, find, render } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { setupRenderingTest } from 'dealfront/tests/helpers';
import { module, test } from 'qunit';
import GithubForm from 'dealfront/components/github-form';

module('Integration | Component | github-form', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    const onSubmit = () => {};
    await render(
      <template>
        <GithubForm @orgsLoading={{false}} @orgName="" @onSubmit={{onSubmit}} />
      </template>,
    );

    assert
      .dom('[data-test-input="access-token"]')
      .hasValue()
      .hasAttribute('readonly', 'true');

    assert.dom('[data-test-input="gh-org-name"]').hasNoValue();
  });

  test('input validation handling', async function (assert) {
    const onSubmit = () => {};
    await render(
      <template>
        <GithubForm @orgsLoading={{false}} @orgName="" @onSubmit={{onSubmit}} />
      </template>,
    );
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
    class TestContext {
      @tracked orgsLoading = false;
      submittedValue = undefined;

      onSubmit = (value: string) => {
        this.submittedValue = value;
        this.orgsLoading = true; // Simulate loading state
      };
    }

    const context = new TestContext();

    await render(
      <template>
        <GithubForm
          @orgsLoading={{context.orgsLoading}}
          @orgName=""
          @onSubmit={{context.onSubmit}}
        />
      </template>,
    );
    await fillIn('[data-test-input="gh-org-name"]', 'github');
    assert.dom('[data-test-submit-button]').hasText('Get Your Repos');
    await click('[data-test-submit-button]');

    assert.equal(
      context.submittedValue,
      'github',
      'submitted value is correct',
    );
    assert
      .dom('[data-test-submit-button]')
      .hasText('⏳ Loading...')
      .isDisabled();
  });
});
