# Prisma Shell Config

{
  pkgs ? import <nixpkgs> { },
}:

let
  prisma-engines = pkgs.prisma-engines;

  libs = with pkgs; [
    openssl
    stdenv.cc.cc
    zlib
    libffi
  ];
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs
    pnpm
    prisma-engines
    nodePackages.prisma
  ];

  shellHook = ''
    QUERY_ENGINE_PATH=$(find ${pkgs.nodePackages.prisma} ${prisma-engines} -name "libquery_engine.node" -o -name "*.so.node" 2>/dev/null | head -n 1)

    if [ -n "$QUERY_ENGINE_PATH" ]; then
      export PRISMA_QUERY_ENGINE_LIBRARY="$QUERY_ENGINE_PATH"
      SOURCE_INFO="Nix Store"
    else
      LOCAL_NODE_MODULES_ENGINE=$(find $(pwd)/node_modules -name "libquery_engine-debian-openssl-3.0.x.so.node" 2>/dev/null | head -n 1)
      if [ -n "$LOCAL_NODE_MODULES_ENGINE" ]; then
        export PRISMA_QUERY_ENGINE_LIBRARY="$LOCAL_NODE_MODULES_ENGINE"
        SOURCE_INFO="Local node_modules"
      else
        SOURCE_INFO="NOT FOUND"
      fi
    fi

    export PRISMA_SCHEMA_ENGINE_BINARY="${prisma-engines}/bin/schema-engine"
    export PRISMA_QUERY_ENGINE_BINARY="${prisma-engines}/bin/query-engine"

    export PRISMA_CLI_BINARY_TARGETS="debian-openssl-3.0.x"
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath libs}"

    echo "════════════════ PRISMA ENGINE REPORT ════════════════"
    echo "  Source Query Lib  : $SOURCE_INFO"
    echo "  Query Lib Path    : $PRISMA_QUERY_ENGINE_LIBRARY"
    echo "  Schema Bin Path   : $PRISMA_SCHEMA_ENGINE_BINARY"
    echo "  Query Bin Path    : $PRISMA_QUERY_ENGINE_BINARY"
    echo "══════════════════════════════════════════════════════"

    if [ "$SOURCE_INFO" = "NOT FOUND" ]; then
      echo "WARNING: Query Engine not found! Run 'pnpm install' first."
    else
      echo "Prisma Environment Ready!"
    fi
  '';
}
