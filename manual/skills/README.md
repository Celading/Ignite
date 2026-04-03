# Ignite Skills

This section explains what "skills" mean in the Ignite repository and how to use AI coding assistants responsibly when building services with Ignite.

## What a skill is

In this repository, a "skill" is a reusable context pack for collaborators, whether that collaborator is:

- a human maintainer
- Codex
- OpenCode
- Claude Code
- another code assistant with repository-aware prompts

A good skill gives the assistant the right boundaries before it writes code:

- what Ignite already supports
- what public wording is allowed
- which samples are the reference path
- which checks must pass before a change is considered ready

## Start here

- `manual/skills/ignite-service-build-with-ai.md`

Use that guide when you want an assistant to help scaffold or refactor an Ignite-based service without drifting into unsupported promises or internal-only implementation details.

## Core rule

Assistants can help accelerate service building, tests, samples, and docs.
They should not silently redefine Ignite's public positioning, release promises, or production support boundaries.
