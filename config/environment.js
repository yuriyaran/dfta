'use strict';

module.exports = function (environment) {
  const ENV = {
    modulePrefix: 'dealfront',
    environment,
    rootURL: '/',
    locationType: 'history',
    EmberENV: {
      EXTEND_PROTOTYPES: false,
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. EMBER_NATIVE_DECORATOR_SUPPORT: true
      },
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
    },

    GITHUB_PAT_CLASSIC: '',
  };

  if (environment === 'development') {
    ENV.GITHUB_PAT_CLASSIC = process.env.GITHUB_PAT_CLASSIC;
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    // ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
    ENV.APP.autoboot = false;

    ENV.GITHUB_PAT_CLASSIC = 'GITHUB_PAT_CLASSIC';
  }

  if (environment === 'production') {
    // here you can enable a production-specific feature
  }

  return ENV;
};
