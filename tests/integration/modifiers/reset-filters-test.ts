import { render, type TestContext } from '@ember/test-helpers';
import { hbs } from 'ember-cli-htmlbars';
import { setupRenderingTest } from 'ember-qunit';
import { module, test } from 'qunit';

interface ResetFiltersTestContext extends TestContext {
  dummyFunction: () => void;
}

module('Integration | Modifier | reset-filters', function (hooks) {
  setupRenderingTest(hooks);

  test('it calls a passed function', async function (this: ResetFiltersTestContext, assert) {
    this.dummyFunction = () => {
      assert.ok(true);
    };

    await render(hbs`<div {{reset-filters this.dummyFunction}}></div>`);
  });
});
