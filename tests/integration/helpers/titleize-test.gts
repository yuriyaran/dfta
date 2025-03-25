import { module, test } from 'qunit';
import { setupRenderingTest } from 'dealfront/tests/helpers';
import { render } from '@ember/test-helpers';
import titleize from 'dealfront/helpers/titleize';

module('Integration | Helper | titleize', function (hooks) {
  setupRenderingTest(hooks);

  test('it titleizes strings', async function (assert) {
    const strings = [
      { inStr: 'branch', outStr: 'Branch' },
      { inStr: 'camelCase', outStr: 'Camelcase' },
      { inStr: 'CAPS', outStr: 'Caps' },
    ];

    for (const { inStr, outStr } of strings) {
      await render(<template>{{titleize inStr}}</template>);
      assert.dom().hasText(outStr);
    }
  });
});
