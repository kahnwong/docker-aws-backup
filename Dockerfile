# hadolint ignore=DL3007
FROM nixos/nix:latest AS builder

# hadolint ignore=DL3059
RUN <<EOF bash
  nix-channel --update
  nix-env -iA nixpkgs.bash nixpkgs.gnutar nixpkgs.gzip nixpkgs.postgresql_18 nixpkgs.awscli2
EOF

# can't use EOF format here
# hadolint ignore=SC2046
RUN mkdir -p /tmp/nix-store-closure && \
    cp -R $(nix-store -qR $(which bash gnutar gzip psql aws)) /tmp/nix-store-closure

FROM debian:trixie-slim
COPY --from=builder /tmp/nix-store-closure /nix/store
COPY --from=builder /root/.nix-profile/bin /usr/local/bin

# this stays here to prevent curl SSL error
RUN <<EOF bash
  apt update
  apt install curl ca-certificates -y --no-install-recommends
  apt-get clean
  rm -rf /var/lib/apt/lists/*
EOF

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
