{ pkgs ? import <nixpkgs> {} }:

let
  prisma-pkg = pkgs.prisma-engines_6;
in
pkgs.mkShell {
  buildInputs = [
    pkgs.prisma-engines_6
    pkgs.nodePackages.prisma
    pkgs.openssl
    pkgs.zlib
    pkgs.stdenv.cc.cc.lib
  ];

  shellHook = ''
    export PRISMA_SCHEMA_ENGINE_BINARY="${prisma-pkg}/bin/schema-engine"
    export PRISMA_QUERY_ENGINE_BINARY="${prisma-pkg}/bin/query-engine"
    export PRISMA_FMT_BINARY="${prisma-pkg}/bin/prisma-fmt"

    export PRISMA_QUERY_ENGINE_LIBRARY="${prisma-pkg}/lib/libquery_engine.node"

    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.openssl pkgs.zlib pkgs.stdenv.cc.cc.lib ]}:$LD_LIBRARY_PATH"

    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"

    echo "Prisma Engines v6.x (Nix) Loaded!"
  '';
}
