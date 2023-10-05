{
  inputs = {
    # equivalent to `nixpkgs = { url = "..."; };
    nixpkgs.url = "github:NixOS/nixpkgs/be28f5521e1d3fec2bd22928f721120725aba272";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }: # destructuring of self for input from own set and the elements of the input set.
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        clightning-dev = (pkgs.clightning.overrideDerivation (attrs: {
          configureFlags = [ "--enable-developer" "--disable-valgrind" ];
          name = attrs.name + "-dev";
        }));
      in
      with pkgs;
      {
        devShells.default = mkShell
          {
            packages = [
              bitcoind
              elementsd
              clightning-dev
              clightning
              lnd
              openssl
              boltbrowser
              gotools
              jq
              nodePackages.mermaid-cli
              protoc-gen-go
              protoc-gen-go-grpc
              protobuf
              grpc-gateway
            ];
            buildInputs = [ go_1_19 ];
            shellHook = ''
              echo "Welcome to our shell!"
              export LIGHTNINGD="${clightning}/bin/lightningd"
              export LIGHTNINGD_CLI="${clightning}/bin/lightningd"
              export LIGHTNINGD_DEV="${clightning-dev}/bin/lightningd"
              export LIGHTNINGD_DEV_CLI="${clightning-dev}/bin/lightning-cli"
            '';
          };
      }
    ); #outputs is a function of inputs;
}
