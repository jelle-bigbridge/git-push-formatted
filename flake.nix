{
  description = "git-push-formatted";

  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , flake-utils
    }: flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
    let
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (self: super: with self; {
            nushell = pkgs-unstable.nushell;
            gum = pkgs-unstable.gum.overrideAttrs (old: {
              patches = (o.patches or [ ]) ++ [
                ./resources/patches/gum-output-on-error.patch
              ];
            });
          })
        ];
      };

      nuShell = "${pkgs.nushell}/bin/nu";

      writeNuScript = name: contents: pkgs.writeScriptBin name ''
        #! ${nuShell}

        ${contents}
      '';

      lib = pkgs.lib;

      maybeLocalSsh = if pkgs.stdenv.isLinux then pkgs.openssh else
      (pkgs.runCommandLocal "ssh-link" { } ''
        mkdir -p $out/bin
        ln -s /usr/bin/ssh $out/bin/ssh
      '');

      git-push-formatted = pkgs.symlinkJoin {
        name = "git-push-formatted";
        nativeBuildInputs = [ pkgs.makeWrapper ];
        paths = [ (writeNuScript "git-push-formatted" (builtins.readFile ./git-push-formatted.nu)) ];

        postBuild =
          let
            path = with pkgs; lib.makeBinPath [
              git
              gitAndTools.git-absorb
              nodejs-16_x
              bash # Seems that prettier requires this
              maybeLocalSsh
              gum
            ];
          in
          ''
            if test -e $out/bin/git-push-formatted; then
              wrapProgram $out/bin/git-push-formatted \
                --set PATH "${path}"
            fi
          '';
      };
    in
    {
      packages =
        rec {
          default = git-push-formatted;
          inherit git-push-formatted;
        };
    }
    );
}

