'use strict';

// Application template: single v* train, Chart.yaml version+appVersion bumped in lockstep with the
// release (the old .releaserc.json committed Chart.yaml back but nothing ever bumped it). Rename the
// chart path along with the rest of the application-application placeholders when instantiating.
const { makeConfig } = require('@webgrip/semantic-release-config');

module.exports = makeConfig({
  manifest: 'helm',
  chartPath: 'ops/helm/application-application',
  prepareCmd: 'yq -i \'.appVersion = "${nextRelease.version}"\' ops/helm/application-application/Chart.yaml',
});
