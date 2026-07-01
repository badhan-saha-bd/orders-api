# NOTES

## What I fixed

| Area | Problem found | Fix applied | Why it mattered |
| --- | --- | --- | --- |
| Flask app | The app listened on `127.0.0.1`, so it would not be reachable through Docker port publishing. | Changed the runtime bind address to `0.0.0.0` and made `PORT` configurable. | Containers need to listen on all interfaces for published ports to work. |
| Flask app | Debug mode was enabled in the production entrypoint. | Made debug opt-in through `FLASK_DEBUG`. | Debug mode can expose internals and should not run by default. |
| Flask app | `SECRET_KEY` was hardcoded in source. | Read it from `SECRET_KEY`, with a local-only fallback. | Secrets should not be committed or baked into images. |
| Dependencies | `flask` was unpinned. | Pinned Flask and added Gunicorn as the production WSGI server. | Reproducible builds are easier to debug and safer to deploy. |
| Tests | CI had a `pytest || true` step and no test. | Added a small `/healthz` test and made CI fail on test failure. | A broken service should stop the pipeline. |
| Dockerfile | Used `python:latest`, installed build tools, curl, and vim, and ran as root. | Switched to `python:3.12-slim`, removed unnecessary apt packages, installed with `--no-cache-dir`, added a non-root user, and added a healthcheck. | This reduces image size, improves reproducibility, and lowers container risk. |
| Dockerfile | The container started Flask's development server. | Start the app with Gunicorn. | Gunicorn is a more appropriate production process manager for Flask. |
| Compose | Published host port `5000` to container port `8080`, but the app used `5000`. | Changed the mapping to `5000:5000`. | `curl http://localhost:5000/healthz` now reaches the app. |
| Compose | The database used `postgres:latest` and a hardcoded password, and the API depended on it even though the app does not use it. | Pinned Postgres to `16-alpine`, moved credentials to environment defaults, added a healthcheck and volume, and put the DB behind a `db` profile. | Local runs stay lighter by default, while a database remains available when needed. |
| CI | The workflow did not check out the repository. | Added `actions/checkout`. | Later steps need the source tree. |
| CI | The pipeline logged into a registry with hardcoded credentials and pushed `latest` on every push. | Removed the push step and kept a deterministic image build tagged with the commit SHA. | Avoids leaked credentials and surprise deployments from CI. |
| Terraform | The EC2 instance and RDS database were oversized and expensive. | Replaced them with a small ECS Fargate service definition. | The service is tiny and does not need large always-on compute or database capacity. |
| Terraform | SSH and API ports were open to the world. | Removed SSH entirely and made API ingress CIDRs configurable, defaulting to private RFC1918 space. | Reduces public attack surface. |
| Terraform | Database password was hardcoded in configuration. | Removed the unused RDS database and inject the Flask secret from Secrets Manager or SSM Parameter Store by ARN. | Keeps secrets out of source and Terraform variables. |
| Terraform | There was no version pinning or provider constraint. | Added Terraform and AWS provider version constraints. | Makes validation and future plans more repeatable. |
| Terraform | There were no logs for the running service. | Added a CloudWatch log group and ECS awslogs configuration. | Basic logs are needed for operations and debugging. |

## Validation performed

- Ran `python3 -m pytest -q`: passed.
- Built the Docker image on the provided VM.
- Ran the container and verified `curl http://localhost:5000/healthz` returns `{"status":"healthy"}`.
- Validated `docker compose config`.
- Validated Terraform using the official Terraform Docker image.

## Follow-ups I would do with more time

- Add a real image publish job using OIDC or GitHub-provided credentials, not static registry credentials.
- Add an ALB or API Gateway in front of ECS if the service needs stable public ingress.
- Add application database integration only if orders need persistence; right now the Flask app serves static sample data, so I avoided keeping an unused database running by default.
- Add request logging, structured JSON logs, and production-ready observability once the expected runtime platform is known.
