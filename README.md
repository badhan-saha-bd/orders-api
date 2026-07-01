# Junior DevOps / Cloud Engineer — Practical Assessment

Welcome, and thanks for taking the time. This is a **fix-it exercise**, not a build-from-scratch one — closer to a real day on the job than a whiteboard puzzle.

## The scenario

The `orders-api` service below was thrown together in a hurry by someone who has since left. It's a small Flask app that's meant to run in a container, get built by CI, and deploy onto AWS. **Right now, most of it is broken, insecure, or wasteful.**

Your job is to get it working and make it something you'd be comfortable putting your name on.

## What's in the repo

```
app/                    the Flask application + requirements
Dockerfile              containerises the app
docker-compose.yml      local run for app + database
.github/workflows/ci.yml   the CI pipeline
infra/main.tf           the AWS infrastructure (Terraform)
```

## Your tasks

1. **Make it run.** Get the app building and reachable in a container. When it works, `curl http://localhost:5000/healthz` should return a healthy response from the running container.
2. **Fix what's wrong.** There are correctness, security, reliability, and cost problems scattered across every file. Fix the ones you think matter.
3. **Explain yourself.** In a file called `NOTES.md`, list each problem you found, the fix you applied, and one line on *why it mattered*. If you found something but chose **not** to fix it, say why. If you ran out of time, tell us what you'd do next.

## Ground rules

- **Time-box: ~2-3 hours.** We mean it. Do not overbuild. We would rather see a partial job with sharp reasoning than a perfect job you spent your whole weekend on. If you hit the time limit, stop and write up what's left.
- **AI tools are allowed and encouraged** (Cursor, Copilot, Claude, whatever you use). We use them too. But you must be able to explain every change you make — we'll ask. "The AI suggested it" is not an answer we accept.
- **You do not need a real AWS account.** `terraform validate` / `terraform plan` is enough; you're being judged on the config, not on a live deploy.
- Don't worry about polishing things we didn't ask for. Scope discipline is part of the test.

## How to submit

A link to a repo (or a zip) containing your fixes and your `NOTES.md`. We'll follow up with a short 20-30 minute call to walk through your reasoning.

Good luck — we're more interested in how you think than in whether you catch every single thing.
