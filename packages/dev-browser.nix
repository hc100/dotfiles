{
  buildNpmPackage,
  fetchurl,
  stdenv,
}:

buildNpmPackage rec {
  pname = "dev-browser";
  version = "0.2.7";

  src = fetchurl {
    url = "https://registry.npmjs.org/dev-browser/-/dev-browser-${version}.tgz";
    hash = "sha256-eneamhzL1gs/AR2R2JUBbu8BaAaYn91guLEwO5EaY+8=";
  };

  nativeBinary = fetchurl {
    url = "https://github.com/SawyerHood/dev-browser/releases/download/v${version}/dev-browser-darwin-arm64";
    hash = "sha256-MKJahYzLGPxfxix3hCAxzdRe2v/i/aq30P8aSP2pXjI=";
  };

  postPatch = ''
    cp ${./dev-browser-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-WP1syISdHFhXP3srfrGKHvhg5e8Gf4XnJ+oB/qM/TuU=";

  npmFlags = [ "--ignore-scripts" ];

  dontNpmBuild = true;

  postInstall = ''
    binary_name="dev-browser-darwin-arm64"
    install -Dm755 "$nativeBinary" "$out/lib/node_modules/dev-browser/bin/$binary_name"

    rm -f "$out/bin/dev-browser"
    makeWrapper "$out/lib/node_modules/dev-browser/bin/$binary_name" "$out/bin/dev-browser"
  '';

  meta.platforms = [ "aarch64-darwin" ];
}
