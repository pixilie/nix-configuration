{
  python = {
    path = ./python;
    description = "template for python project";
    welcomeText = "direnv allow";
  };

  c = {
    path = ./c;
    description = "Template for C project";
    welcomeText = "direnv allow";
  };

  rust = {
    path = ./rust;
    description = "Flake for Rust setup";
    welcomeText = "`direnv allow`";
  };
}
