# docker-aws-backup

Nix image with awscli, tar, gzip, curl, postgresql.

## Usage
```bash
docker run --env-file .env -v $(pwd)/data:/data docker-aws-backup
```
