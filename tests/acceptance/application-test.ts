import Service from '@ember/service';
import {
  click,
  currentURL,
  fillIn,
  findAll,
  visit,
  waitFor,
} from '@ember/test-helpers';
import { type Repository } from 'dealfront/controllers/application';
import DFNotificationsService from 'dealfront/services/df-notifications';
import { type GithubServiceType } from 'dealfront/services/github';
import { setupApplicationTest } from 'dealfront/tests/helpers';
import { module, test } from 'qunit';

module('Acceptance | application', function (hooks) {
  setupApplicationTest(hooks);

  const repositories: Repository[] = [
    {
      name: 'ember',
      url: 'https://api.github.com/repos/emberjs/rfcs',
      htmlUrl: 'https://github.com/emberjs/rfcs',
      language: null,
      private: false,
    },
    {
      name: 'guides',
      url: 'https://api.github.com/repos/emberjs/guides',
      htmlUrl: 'https://github.com/emberjs/guides',
      language: 'CSS',
      private: false,
    },
    {
      name: 'ember-mocha',
      url: 'https://api.github.com/repos/emberjs/ember-mocha',
      htmlUrl: 'https://github.com/emberjs/ember-mocha',
      language: 'JavaScript',
      private: true,
    },
  ];

  hooks.beforeEach(async function () {
    class StubGithubService extends Service {
      getOrgRepos() {
        return new Promise((resolve) => {
          resolve(
            new Response(JSON.stringify(repositories), {
              status: 200,
              headers: { 'Content-Type': 'application/json' },
            }),
          );
        });
      }
      async getRepoBranches() {
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
    this.owner.register('service:dfNotifications', DFNotificationsService);

    await visit('/');
  });

  test('visiting /', async function (assert) {
    assert.strictEqual(currentURL(), '/');
  });

  module('handles API calls', function (hooks) {
    test('succcessful response: repositories & branches', async function (assert) {
      const repoName = 'emberjs';

      assert
        .dom('[data-test-list="empty"]')
        .isVisible('Placeholder visible if repositories list is empty');

      await fillIn('[data-test-input="gh-org-name"]', repoName);
      await click('[data-test-submit-button]');

      assert.dom('[data-test-caption="org-name"]').hasText(repoName);
      assert.equal(
        findAll('[data-test-row-repo]').length,
        repositories.length,
        'All repositories are listed',
      );

      await click('[data-test-row-repo] > td');

      assert
        .dom(`[data-test-row-branches="${repositories[0]!.name}"]`)
        .hasText(
          '3 Branches: main, dev, feature',
          'branches endpoint successful response',
        );
    });

    test('repositories: failed response', async function (assert) {
      const githubService = this.owner.lookup(
        'service:github',
      ) as GithubServiceType;
      githubService.getOrgRepos = () => {
        return new Promise((resolve) => {
          resolve(
            new Response(JSON.stringify({ message: 'Not Found' }), {
              status: 404,
              headers: { 'Content-Type': 'application/json' },
            }),
          );
        });
      };

      await fillIn('[data-test-input="gh-org-name"]', 'failed-one');
      await click('[data-test-submit-button]');

      await waitFor('[data-test-notification-message="error"]');
      assert
        .dom('[data-test-notification-message="error"]')
        .hasText('Not Found: failed-one');
    });

    module('it filters repositories', function (hooks) {
      test('filters by language & privacy', async function (assert) {
        await fillIn('[data-test-input="gh-org-name"]', 'org-name');
        await click('[data-test-submit-button]');

        assert
          .dom('[data-test-input="radio-lang-All"]')
          .isChecked('filter "All languages" is selected by default');
        assert
          .dom('[data-test-input="radio-priv-All"]')
          .isChecked('filter "All privacy" is selected by default');

        await click('[data-test-label="radio-lang-null"]');
        assert.equal(
          findAll('[data-test-row-repo]').length,
          1,
          'should filter repositories by language',
        );
        assert
          .dom('[data-test-row-repo] > td')
          .hasText(repositories.find((r) => r.language === null)!.name);

        await click('[data-test-label="radio-lang-All"]');
        await click('[data-test-label="radio-priv-Private"]');

        assert.equal(
          findAll('[data-test-row-repo]').length,
          1,
          'should filter private repositories',
        );
        assert
          .dom('[data-test-row-repo] > td')
          .hasText(repositories.find((r) => r.private)!.name);
      });

      test('filters are reset on a new org search', async function (assert) {
        await fillIn('[data-test-input="gh-org-name"]', 'org-name');
        await click('[data-test-submit-button]');

        await click('[data-test-label="radio-lang-CSS"]');
        await click('[data-test-label="radio-priv-Public"]');
        assert.equal(
          findAll('[data-test-row-repo]').length,
          1,
          'should return one repository',
        );

        await fillIn('[data-test-input="gh-org-name"]', 'rust');
        await click('[data-test-submit-button]');

        assert
          .dom('[data-test-input="radio-lang-All"]')
          .isChecked('should reset filter to default "All languages"');
        assert
          .dom('[data-test-input="radio-priv-All"]')
          .isChecked('should reset filter to default "All privacy"');
      });
    });
  });
});
