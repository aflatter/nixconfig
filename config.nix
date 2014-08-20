{
  packageOverrides = pkgs: rec {
    userEnv = pkgs.buildEnv {
      name = "userEnv";
      paths = [ pkgs.git pkgs.vim pkgs.unzip ];
    };
  };
}
