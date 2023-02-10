with (import <nixpkgs> { });
let 
 tf-tests = pkgs.writeShellScriptBin "tf-tests" ''
  terraform -chdir=$PWD/tests $1 
 '';
boundary-arm = pkgs.boundary.overrideAttrs (finalAttrs: previousAttrs: {
    src = let
      inherit (stdenv.hostPlatform) system;
      version = "0.11.0";
      selectSystem = attrs: attrs.${system} or (throw "Unsupported system: ${system}");
      suffix = selectSystem {
        x86_64-linux = "linux_amd64";
        aarch64-linux = "linux_arm64";
        x86_64-darwin = "darwin_amd64";
        aarch64-darwin = "darwin_arm64";
      };
      sha256 = selectSystem {
        x86_64-linux = "sha256-Dje9uSdE0KBX6bqx4nOtkzeeZvlHFqIlETAEbnw2tp0=";
        aarch64-linux = "sha256-0eSqfTwViFdDEoQ5kKjmJI+3jfmk1ZwJQh/UIM7LsA4=";
        x86_64-darwin = "sha256-9cxBdp4BxwtfSsvRr5ZSCeMWvttf1r8WaNV38DG0Iog=";
        aarch64-darwin = "sha256-dr4XXFOADO6eiSpIc0xfLJA4aX0oxcuw+TJn1Fzv/v0=";
      }; 
    in 
    fetchzip {
      url = "https://releases.hashicorp.com/boundary/${version}/boundary_${version}_${suffix}.zip";
      inherit sha256;
    };
});
helloWithDebug = pkgs.hello.overrideAttrs (finalAttrs: previousAttrs: {
  separateDebugInfo = true;
});
in 
stdenv.mkDerivation {
  shellHook = ''
    set -a
    source .env
    set +a
  '';
  name = "gke-k8s";
  buildInputs = [
    tf-tests
    google-cloud-sdk
    terraform 
    terragrunt
    jq
    graphviz-nox
    kubectl
    kubernetes-helm-wrapped
    vault
    boundary-arm
  ];
}