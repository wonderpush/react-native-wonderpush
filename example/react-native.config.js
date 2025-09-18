const path = require('path');
const pkg = require('../package.json');
const fcmpkg = require('../fcm/package.json');
const hcmpkg = require('../hcm/package.json');

module.exports = {
  project: {
    ios: {
      automaticPodsInstallation: true,
    },
  },
  dependencies: {
    [pkg.name]: {
      root: path.join(__dirname, '..'),
      platforms: {
        // Codegen script incorrectly fails without this
        // So we explicitly specify the platforms with empty object
        ios: {},
        android: {},
      },
    },
    [fcmpkg.name]: {
      root: path.join(__dirname, '../fcm'),
      platforms: {
        // Codegen script incorrectly fails without this
        // So we explicitly specify the platforms with empty object
        android: {},
      },
    },
    [hcmpkg.name]: {
      root: path.join(__dirname, '../hcm'),
      platforms: {
        // Codegen script incorrectly fails without this
        // So we explicitly specify the platforms with empty object
        android: {},
      },
    },
  },
};
