import Controller from '@ember/controller';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import DFNotificationsService from 'dealfront/services/df-notifications';
import GithubService from 'dealfront/services/github';
import { task } from 'ember-concurrency';

export type Repository = {
  name: string;
  url: string;
  language: string | null;
  private: boolean;
};

type Branch = {
  name: string;
};

export default class ApplicationController extends Controller {
  @service declare dfNotifications: DFNotificationsService;
  @service declare github: GithubService;

  @tracked orgName: string = '';
  @tracked repositories: Repository[] = [];

  updateOrgName = (name: string) => {
    this.orgName = name;
  };

  getOrgRepos = task(async (orgName) => {
    try {
      const response = await this.github.getOrgRepos(orgName);
      const { ok, status } = response;

      if (ok) {
        this.updateOrgName(orgName);

        const repos = await response.json();
        this.repositories = [
          ...repos.map(
            ({ name, url, language, private: isPrivate }: Repository) => {
              return {
                name,
                url,
                language,
                private: isPrivate,
              };
            },
          ),
        ];
      } else if (status === 404) {
        const notFoundResponse = await response.json();
        this.dfNotifications.notifyError(
          `${notFoundResponse.message}: ${orgName}`,
        );
      }
    } catch (error: unknown) {
      if (error instanceof Error) {
        this.dfNotifications.notifyError(`${error.message}: ${orgName}`);
      }
      console.error(error);
    }
  });

  getRepoBranches = task({ drop: true }, async (url: string) => {
    try {
      const response = await this.github.getRepoBranches(url);
      const { ok, status } = response;

      if (ok) {
        const branches = await response.json();
        return branches.map(({ name }: Branch) => name).join(', ');
      } else {
        const failedResponse = await response.json();
        this.dfNotifications.notifyError(
          `${failedResponse.message}: couldn't load branches`,
        );
      }
    } catch (error: unknown) {
      if (error instanceof Error) {
        this.dfNotifications.notifyError(
          `${error.message}: couldn't load branches`,
        );
      }
      console.error(error);
    }
  });
}
