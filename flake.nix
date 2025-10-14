{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs =
    { nixpkgs, ... }:
    {
      lib.fromJsonSchema = (import ./fromJsonSchema.nix { inherit nixpkgs; });
    };
}
