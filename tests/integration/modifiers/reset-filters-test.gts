import { render, type TestContext } from '@ember/test-helpers';
import { setupRenderingTest } from 'ember-qunit';
import { module, test } from 'qunit';
import ResetFilters from 'dealfront/modifiers/reset-filters';

interface ResetFiltersTestContext extends TestContext {
  dummyFunction: () => void;
}

module('Integration | Modifier | reset-filters', function (hooks) {
  setupRenderingTest(hooks);

  test('it calls a passed function', async function (this: ResetFiltersTestContext, assert) {
    const dummyFunction = () => {
      assert.ok(true);
    };

    await render(
      <template>
        <div {{ResetFilters dummyFunction}}></div>
      </template>,
    );
  });
});
