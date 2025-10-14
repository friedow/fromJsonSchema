{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs =
    { self, nixpkgs, ... }:
    {
      lib.fromJsonSchema = (import ./fromJsonSchema.nix { inherit nixpkgs; });

      tests.convertMarkdownlintConfig = self.lib.fromJsonSchema (
        builtins.fromJSON (
          builtins.readFile (
            builtins.fetchurl {
              sha256 = "04wbgrzl3d6mdnvqi8142gz69006hjvrwhd7gvkx7wyqqkw9rpj4";
              url = "https://raw.githubusercontent.com/DavidAnson/markdownlint/main/schema/markdownlint-config-schema.json";
            }
          )
        )
      );
    };
}
