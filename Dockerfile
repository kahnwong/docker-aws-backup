FROM nixos/nix:latest

RUN nix-channel --update
RUN nix-env -iA nixpkgs.awscli2 && \
  nix-env -iA nixpkgs.gnutar && \
  nix-env -iA nixpkgs.gzip && \
  nix-env -iA nixpkgs.postgresql
