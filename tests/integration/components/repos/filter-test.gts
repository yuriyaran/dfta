import { click, render } from '@ember/test-helpers';
import { type FilterArgs } from 'dealfront/components/repos/types';
import { setupRenderingTest } from 'dealfront/tests/helpers';
import { module, test } from 'qunit';
import ReposFilter from 'dealfront/components/repos/filter';

module('Integration | Component | repos/filter', function (hooks) {
  setupRenderingTest(hooks);

  test('it filters', async function (assert) {
    const langs = ['JavaScript', 'TypeScript', null];
    const privacy = ['All', 'Private', 'Public'];
    let selectedFilter: string | undefined = 'All';
    const onFilter = ({ language, privacy }: FilterArgs) => {
      selectedFilter = language || privacy;
    };

    await render(
      <template>
        <ReposFilter
          @langs={{langs}}
          @privacy={{privacy}}
          @onFilter={{onFilter}}
        />
      </template>,
    );

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
