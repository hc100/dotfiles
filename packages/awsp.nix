{
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "awsp";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "johnnyopao";
    repo = "awsp";
    rev = "0656893f9521887d3af3d869cc757a64cdfcd179";
    hash = "sha256-QQCO+6mChD1XxZILr4NQyQX9bsu4WgYyHliopwkRDSk=";
  };

  npmDepsHash = "sha256-hGnq6XSNrE+n5wJqyR4hFLuPRKPTTzRc64F55OlJF+4=";

  dontNpmBuild = true;

  postInstall = ''
    cp "$out/lib/node_modules/awsp/run.sh" "$out/bin/_awsp"
    chmod +x "$out/bin/_awsp"
  '';
}
