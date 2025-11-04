{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wrappers.url = "github:lassulus/wrappers";
    fromJsonSchema.url = "github:friedow/fromJsonSchema";
  };

  outputs =
    {
      nixpkgs,
      fromJsonSchema,
      wrappers,
      ...
    }:
    {
      wrapperModules.markdownlint = wrappers.lib.wrapModule (
        { config, ... }:
        let
          jsonFmt = config.pkgs.formats.json { };
          jsonSchema = builtins.fromJSON (
            builtins.readFile (
              builtins.fetchurl {
                url = "https://raw.githubusercontent.com/DavidAnson/markdownlint/main/schema/markdownlint-config-schema.json";
                sha256 = "04wbgrzl3d6mdnvqi8142gz69006hjvrwhd7gvkx7wyqqkw9rpj4";
              }
            )
          );
        in
        {
          options = {
            settings = (fromJsonSchema.lib.fromJsonSchema jsonSchema).options;
          };
          config = {
            package = nixpkgs.lib.mkDefault config.pkgs.markdownlint-cli;
            flags."--config-file" = jsonFmt.generate "markdownlint.json" config.settings;
          };
        }
      );
    };
}
