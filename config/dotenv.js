module.exports = function (env) {
  return {
    clientAllowedKeys: ['GITHUB_PAT_CLASSIC'],
    // Fail build when there is missing any of clientAllowedKeys environment variables.
    // By default false.
    failOnMissingKey: false,
  };
};
