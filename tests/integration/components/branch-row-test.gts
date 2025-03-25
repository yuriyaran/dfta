import { module, test } from 'qunit';
import { setupRenderingTest } from 'dealfront/tests/helpers';
import { render, settled } from '@ember/test-helpers';
import { renderSettled } from '@ember/renderer';
import Service from '@ember/service';
import BranchRow from 'dealfront/components/branches-row';
import { type Repository } from 'dealfront/controllers/application';

module('Integration | Component | branches-row', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {});

  test('it is not rendered w/o properties provided', async function (assert) {
    await render(
      <template><BranchRow @selectedRepo="" @repo={{undefined}} /></template>,
    );

    assert.dom('[data-test-branches-row="ember"]').doesNotExist();
  });

  test('it renders', async function (assert) {
    class StubGithubService extends Service {
      getRepoBranches() {
        return new Promise((resolve) => {
          resolve(
            new Response(
              JSON.stringify([
                { name: 'main' },
                { name: 'dev' },
                { name: 'feature' },
              ]),
              {
                status: 200,
                headers: { 'Content-Type': 'application/json' },
              },
            ),
          );
        });
      }
    }
    this.owner.register('service:github', StubGithubService);
    const repo: Repository = {
      name: 'ember',
      url: 'https://api.github.com/repos/emberjs/ember.js',
    };

    void render(
      <template><BranchRow @selectedRepo="ember" @repo={{repo}} /></template>,
    );

    await renderSettled();
    assert
      .dom('[data-test-branches-row="ember"]')
      .hasText(
        '⏳ Loading...',
        'should show loading copy on initial render before data is loaded',
      );

    await settled();
    assert
      .dom('[data-test-branches-row="ember"]')
      .hasText(
        '3 Branches main dev feature',
        'should show branches list once data is loaded',
      );
  });
});
