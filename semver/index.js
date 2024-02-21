const parse = require("semver/functions/parse");

function check(version) {
  const semver = parse(version);
  if (!semver) {
    console.error(`"${version}" is not parseable by node-semver.`);
  } else {
    console.log(`"${version}" is parseable by node-semver.`);
    console.log(semver);
  }
}

check("1.2.3");
check("1.2");
