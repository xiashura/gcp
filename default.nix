with (import <nixpkgs> {});
let 
 tf-tests = pkgs.writeShellScriptBin "tf-tests" ''
  terraform -chdir=$PWD/tests $1 
 '';
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
    kubectl
    kubernetes-helm-wrapped
  ];
}


