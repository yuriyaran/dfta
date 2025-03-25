import { module, test } from 'qunit';
import { setupRenderingTest } from 'dealfront/tests/helpers';
import { render } from '@ember/test-helpers';
import pluralize from 'dealfront/helpers/pluralize';

module('Integration | Helper | pluralize', function (hooks) {
  setupRenderingTest(hooks);

  // TODO: Replace this with your real tests.
  test('it renders', async function (assert) {
    const inputValue = [
      { number: 1, word: 'branch' },
      { number: 12, word: 'branches' },
      { number: 21, word: 'branch' },
    ];

    // await render(<template>{{pluralize inputValue[0] "branch"}}</template>);

    for (const { number, word } of inputValue) {
      await render(<template>{{pluralize number "branch"}}</template>);
      assert.dom().hasText(word);
    }
    // assert.dom().hasText('12 branches');
  });
});
