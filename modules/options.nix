{ lib, ... }:

{
  options.useHelixCache = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether to use cache or not";
  };
  options.useFulli3 = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether to use the whole custom  i3 config or not";
  };
}
