{
   description = "A devbox shell";

   inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/41da1e3ea8e23e094e5e3eeb1e6b830468a7399e?narHash=sha256-jp0D4vzBcRKwNZwfY4BcWHemLGUs4JrS3X9w5k%2FJYDA%3D";
   };

   outputs = {
     self,
     nixpkgs,
   }:
      let
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      in
      {
        devShells.aarch64-darwin.default = pkgs.mkShell {
          buildInputs = [
            (builtins.trace "downloading tmuxinator@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/rbqxn9k8krp733ajf1ysf3skwl82vp6m-tmuxinator-3.3.3";
              inputAddressed = true;
            }))
            (builtins.trace "downloading tealdeer@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/6md9mx803pcc5z0qzjbr3mkqh7yrrbny-tealdeer-1.7.2";
              inputAddressed = true;
            }))
            (builtins.trace "downloading neovim@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/4k6v3m3q2afh57a43cdnhg1vlphz2yhr-neovim-0.11.2";
              inputAddressed = true;
            }))
            (builtins.trace "downloading ripgrep@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/7sm130rzasd97g50bclmbdvn0s6fdprs-ripgrep-14.1.1";
              inputAddressed = true;
            }))
            (builtins.trace "downloading fd@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/wigamlnywkjdgqf9xb2079p27nhy32h6-fd-10.2.0";
              inputAddressed = true;
            }))
            (builtins.trace "downloading zoxide@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/wifvggyv5911qsrk1kzapwkzqad3mzc0-zoxide-0.9.8";
              inputAddressed = true;
            }))
            (builtins.trace "downloading eza@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/qaxhgr89vbz3yx12cw6md403rlays627-eza-0.21.4";
              inputAddressed = true;
            }))
            (builtins.trace "downloading eza@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/855psl13ns20bny0gm5allwpq4f0dgxw-eza-0.21.4-man";
              inputAddressed = true;
            }))
            (builtins.trace "downloading delta@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/0chjdvm118jxp0nfk1hp4hvi87q9hfzs-delta-0.18.2";
              inputAddressed = true;
            }))
            (builtins.trace "downloading bat@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/x46am005zdr73n188dqjvh8yak2rwnrd-bat-0.25.0";
              inputAddressed = true;
            }))
            (builtins.trace "downloading direnv@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/g8hmdwd25ddyrbni7whd255cq7i6kk48-direnv-2.36.0";
              inputAddressed = true;
            }))
            (builtins.trace "downloading jq@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/5v1yqacl2lhgbrzgvbmnxbxah9pdyp2s-jq-1.7.1-bin";
              inputAddressed = true;
            }))
            (builtins.trace "downloading jq@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/6zfpzcwd7m5pkf1bd3sdasjv0rxsxvjg-jq-1.7.1-man";
              inputAddressed = true;
            }))
            (builtins.trace "downloading yq@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/b7fp4z37adfq52dwzx1y54kdb5p9nwgz-python3.12-yq-3.4.3";
              inputAddressed = true;
            }))
            (builtins.trace "downloading atuin@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/dkxmsswa3w28gj60jnfyc6c98r51zkih-atuin-18.6.1";
              inputAddressed = true;
            }))
            (builtins.trace "downloading sqlite@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/cq20rd1ci51s72zv7k29h63clrj6rl0l-sqlite-3.48.0-bin";
              inputAddressed = true;
            }))
            (builtins.trace "downloading sqlite@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/sal36w50bf6hlv076n4bypsyk51rn3ki-sqlite-3.48.0-man";
              inputAddressed = true;
            }))
            (builtins.trace "downloading lua@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/ihfk33d6jm29hh0fc8l6fajakvgrb0mk-lua-5.2.4";
              inputAddressed = true;
            }))
            (builtins.trace "downloading luajit@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/gyyngc8p5kikk9ssa6lm88mkp8xl5c6h-luajit-2.1.1741730670";
              inputAddressed = true;
            }))
            (builtins.trace "downloading luarocks@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/2rp9d9ic2qvljghya81na5snjrzcrh10-luarocks-3.9.1";
              inputAddressed = true;
            }))
            (builtins.trace "downloading sd@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/lprkcz7q42jyvz5693ahjs9hyf2f4y73-sd-1.0.0";
              inputAddressed = true;
            }))
            (builtins.trace "downloading yazi@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/gy7r8iw79rqifckaks26q4dmqplx5qir-yazi-25.5.31";
              inputAddressed = true;
            }))
            (builtins.trace "downloading poppler@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/q76x1h4vqqr6lp8yf7n2m1wni1pnf4zr-poppler-glib-25.05.0";
              inputAddressed = true;
            }))
            (builtins.trace "downloading p7zip@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/rpghr71q3lid1jmplkpqvyllvxgdbzsm-p7zip-17.06";
              inputAddressed = true;
            }))
            (builtins.trace "downloading p7zip@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/1my0rx3djbijkx9anp6spm2ra5xmz563-p7zip-17.06-man";
              inputAddressed = true;
            }))
            (builtins.trace "downloading lazygit@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/zfxsqf5wsrb02kkd39lx29qdnhmwkgr8-lazygit-0.52.0";
              inputAddressed = true;
            }))
            (builtins.trace "downloading wordnet@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/v4zyqach9g07dnflcmn5qxfx5p4xrs1q-wordnet-3.0";
              inputAddressed = true;
            }))
            (builtins.trace "downloading jira-cli-go@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/b00mq65rp4lnh6rqszl25as2y3s5fbhc-jira-cli-go-1.6.0";
              inputAddressed = true;
            }))
            (builtins.trace "downloading gh-dash@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/kcmyxgjakkh5bmllhbwf6slfbpxvms3s-gh-dash-4.16.0";
              inputAddressed = true;
            }))
            (builtins.trace "downloading tmux@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/hb9rmacsyjn2jbkfl12ax66qj9z86w8l-tmux-3.5";
              inputAddressed = true;
            }))
            (builtins.trace "downloading tmux@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/fzmxcplr3rqr0vm642fyschn4n43q43p-tmux-3.5-man";
              inputAddressed = true;
            }))
            (builtins.trace "downloading nodejs@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/2q5an9rpdq4vhc5ag04ajxnzxxqsqchq-nodejs-24.1.0";
              inputAddressed = true;
            }))
            (builtins.trace "downloading du-dust@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/vpwrnl01zq3332g7klck54k4rk355s4f-du-dust-0.9.0";
              inputAddressed = true;
            }))
            (builtins.trace "downloading glow@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/mw69k6ynypwlwj55hq92swckwldx6m9f-glow-2.1.1";
              inputAddressed = true;
            }))
            (builtins.trace "downloading fzf@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/1azm167z54vppj0mr2r5j9f8gzmi87ia-fzf-0.62.0";
              inputAddressed = true;
            }))
            (builtins.trace "downloading fzf@latest" (builtins.fetchClosure {
              
              fromStore = "https://cache.nixos.org";
              fromPath = "/nix/store/qa24maj0wdglp5yvnsfwmwmr0j4iywb0-fzf-0.62.0-man";
              inputAddressed = true;
            }))
          ];
        };
      };
 }
