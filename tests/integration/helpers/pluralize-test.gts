import { module, test } from 'qunit';
import { setupRenderingTest } from 'dealfront/tests/helpers';
import { render } from '@ember/test-helpers';
import pluralize from 'dealfront/helpers/pluralize';

module('Integration | Helper | pluralize', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    const inputValue = [
      { number: 1, word: 'Branch' },
      { number: 12, word: 'Branches' },
      { number: 21, word: 'Branch' },
      { number: 0, word: 'Branches' },
    ];

    for (const { number, word } of inputValue) {
      await render(<template>{{pluralize number "branch"}}</template>);
      assert.dom().hasText(word);
    }
  });
});
