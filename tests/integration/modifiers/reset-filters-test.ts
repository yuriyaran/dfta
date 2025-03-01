import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { hbs } from 'ember-cli-htmlbars';

module('Integration | Modifier | reset-filters', function (hooks) {
  setupRenderingTest(hooks);

  test('it calls a passed function', async function (assert) {
    this.dummyFunction = () => {
      assert.ok(true);
    };

    await render(hbs`<div {{reset-filters this.dummyFunction}}></div>`);
  });
});
