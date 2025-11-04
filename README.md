# fromJsonSchema to nix options

Converts json schema to nix options.
Aims to enable fast creation of nix modules which provide options for all config keys of a tool.

## Usage

1. Define options for a module or wrapper using this library.

   ```nix
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
             tomlFmt = config.pkgs.formats.json { };
             jsonSchema = builtins.fromJSON (
               builtins.readFile (
                 builtins.fetchurl {
                   url = "https://raw.githubusercontent.com/DavidAnson/markdownlint/main/schema/markdownlint-config-schema.json";
                   sha256 = "04wbgrzl3d6mdnvqi8142gz69006hjvrwhd7gvkx7wyqqkw9rpj4";
                 }
               )
             );
             markdownlintConfig = nixpkgs.lib.filterAttrsRecursive (_n: v: v != null) config.settings;
           in
           {
             options = {
               settings = (fromJsonSchema.lib.fromJsonSchema jsonSchema).options;
             };
             config = {
               package = nixpkgs.lib.mkDefault config.pkgs.markdownlint-cli;
               flags."--config-file" = tomlFmt.generate "markdownlint.json" markdownlintConfig;
             };
           }
         );
       };
   }
   ```

2. Enjoy auto generated nix options based on the json schema.

   ```bash
   nix eval .#wrapperModules.markdownlint
   ```
