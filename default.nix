with import <nixpkgs> { };
let
  pname = "spacemacs";
  version = "0.200.13";

  src = fetchFromGitHub {
    owner = "syl20bnr";
    repo = pname;
    rev = "v${version}";
    sha256 = "0m634adqnwqvi8d7qkq7nh8ivfz6cx90idvwd2wiylg4w1hly252";
  };

  script = substituteAll {
    src = ./script.el;
    inherit version;
  };

  packages = runCommand "spacemacs-packages" {} ''
    mkdir -p $out
    cd $out
    mkdir -p spacemacs-files
    cp -r ${src}/* ./spacemacs-files
    touch packages.txt
    cd spacemacs-files
    ${emacs}/bin/emacs --debug --batch --load ${script}
  '';

  packageList = (lib.splitString "\n" (builtins.readFile "${packages}/packages.txt"));

  retrievePackage = p: x: let
    e = p.elpaPackages;
    m = p.melpaPackages;
  in if builtins.hasAttr x e then builtins.getAttr x e else if builtins.hasAttr x m then builtins.getAttr x m else null;

   retrievedPackageList = p: builtins.filter (x: x != null) (map (retrievePackage p) packageList);

  emacspkgs = emacsWithPackages (builtins.deepSeq packageList (builtins.trace packageList (retrievedPackageList)));
in
stdenv.mkDerivation rec {
  inherit src pname version;

  patches = [ ./change-paths.patch ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out
    mkdir -p $out/.emacs.d
    mkdir -p $out/bin
    cp -r * $out/.emacs.d
    makeWrapper "${emacspkgs}/bin/emacs" $out/bin/spacemacs \
      --add-flags "-q -l $out/.emacs.d/init.el"
  '';
}
