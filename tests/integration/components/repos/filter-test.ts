import { click, render } from '@ember/test-helpers';
import { FilterArgs } from 'dealfront/components/repos/filter';
import { setupRenderingTest } from 'dealfront/tests/helpers';
import { hbs } from 'ember-cli-htmlbars';
import { module, test } from 'qunit';

module('Integration | Component | repos/filter', function (hooks) {
  setupRenderingTest(hooks);

  test('it filters', async function (assert) {
    this.set('langs', ['JavaScript', 'TypeScript', null]);
    this.set('privacy', ['All', 'Private', 'Public']);

    let selectedFilter: string = 'All';
    this.set('onFilter', ({ language, privacy }: FilterArgs) => {
      selectedFilter = language || privacy;
    });

    await render(hbs`<Repos::Filter
      @langs={{this.langs}}
      @privacy={{this.privacy}}
      @onFilter={{this.onFilter}}
    />`);

    await click('[data-test-label="radio-lang-JavaScript"]');
    assert.equal(
      selectedFilter,
      'JavaScript',
      'should set "JavaScript" language filter',
    );

    await click('[data-test-label="radio-priv-Private"]');
    assert.equal(
      selectedFilter,
      'Private',
      'should set "Private" privacy filter',
    );
  });
});
