import Service from '@ember/service';
import ENV from 'dealfront/config/environment';

export type GithubServiceType = {
  getOrgRepos(orgName: string): Promise<Response>;
  getRepoBranches(url: string): Promise<Response>;
};

export default class GithubService extends Service {
  pat = ENV.GITHUB_PAT_CLASSIC;

  headers = {
    Accept: 'application/vnd.github+json',
    Authorization: `Bearer ${this.pat}`,
    'X-GitHub-Api-Version': '2022-11-28',
  };

  async getOrgRepos(orgName: string) {
    return await fetch(`https://api.github.com/orgs/${orgName}/repos`, {
      headers: this.headers,
    });
  }

  async getRepoBranches(url: string) {
    return await fetch(`${url}/branches`, {
      headers: this.headers,
    });
  }
}

declare module '@ember/service' {
  interface Registry {
    github: GithubService;
  }
}
