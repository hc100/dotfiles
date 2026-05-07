{
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage rec {
  pname = "speca-cli";
  version = "0.9.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/speca-cli/-/speca-cli-${version}.tgz";
    hash = "sha256-ESOERWrJEBUv+rMvk+zQyI7A0lG4KCpID+OfzOodZUU=";
  };

  postPatch = ''
    cp ${./speca-cli-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-lNK/98viy15rl3IvXR8DRuT0dmthfi9aRPdTeJxbEYE=";

  npmFlags = [ "--ignore-scripts" ];

  dontNpmBuild = true;
}
