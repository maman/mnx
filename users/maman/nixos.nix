{
  inputs,
  pkgs,
  ...
}: {
  users.users.maman = {
    home = "/home/maman";
    shell = pkgs.fish;
  };
}
