{ nixpkgs }:
(
  let
    lib = nixpkgs.lib;

    convertSimpleType =
      jsonSchemaProperty: typeToConvert:
      if typeToConvert == "array" then
        lib.types.listOf (convertType jsonSchemaProperty.items)
      else if typeToConvert == "boolean" then
        lib.types.bool
      else if typeToConvert == "integer" then
        lib.types.int
      else if typeToConvert == "object" then
        if lib.attrsets.hasAttrByPath [ "properties" ] jsonSchemaProperty then
          lib.types.submodule (fromJsonSchema jsonSchemaProperty)
        else
          lib.types.attrs
      else if typeToConvert == "string" then
        lib.types.string
      else
        abort "Converting '${typeToConvert}' into a nix type failed. No convertion for this type was specified.";

    convertType =
      jsonSchemaProperty:
      if lib.isList jsonSchemaProperty.type then
        lib.types.oneOf (map (type: convertSimpleType jsonSchemaProperty type) jsonSchemaProperty.type)
      else
        convertSimpleType jsonSchemaProperty jsonSchemaProperty.type;

    convertPropertyToOption =
      key: value:
      lib.mkOption {
        description = value.description;
        type = convertType value;
        default = value.default;
      };

    fromJsonSchema = jsonSchema: {
      options = (builtins.mapAttrs convertPropertyToOption jsonSchema.properties);
    };

    # jsonSchema = (builtins.fromJSON (builtins.readFile ./markdownlint-config-schema.json));
  in
  fromJsonSchema
)
