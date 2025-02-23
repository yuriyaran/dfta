/**
 * Type declarations for
 *    import config from 'dealfront/config/environment'
 */
declare const config: {
  environment: string;
  modulePrefix: string;
  podModulePrefix: string;
  locationType: 'history' | 'hash' | 'none';
  rootURL: string;
  APP: Record<string, unknown>;
  GITHUB_PAT_CLASSIC: string;
};

export default config;
