{
  stdenvNoCC,
  fetchurl,
}:

# ccusage v20 は npm 本体（ccusage）が optionalDependencies の
# プラットフォーム別ネイティブバイナリを spawn するラッパー構成。
# このリポジトリは aarch64-darwin 固定なので、darwin-arm64 の
# ネイティブバイナリだけを直接取得して配置する。
stdenvNoCC.mkDerivation rec {
  pname = "ccusage";
  version = "20.0.20";

  src = fetchurl {
    url = "https://registry.npmjs.org/@ccusage/ccusage-darwin-arm64/-/ccusage-darwin-arm64-${version}.tgz";
    hash = "sha256-rSdimkXgo+ResWcIDbCq11RQgBNNpoSbbqd0s+1omeE=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/ccusage "$out/bin/ccusage"
    runHook postInstall
  '';

  meta = {
    description = "Analyze Claude Code token usage and costs from local data";
    homepage = "https://ccusage.com/";
    license = "MIT";
    mainProgram = "ccusage";
    platforms = [ "aarch64-darwin" ];
  };
}
