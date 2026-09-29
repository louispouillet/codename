# CODENAME

No application code: a single `Modelfile` and a handful of
plain-text prompts, all running on `granite3.1-moe:3b` via [Ollama](https://ollama.com).

## Structure

```
codename/
├── Modelfile          # the hardened agent
├── Makefile            # build/test/clean helpers (see below)
├── .env.example         # template for local test PASSWORD/CODEWORD
├── scripts/chat.sh       # sends one message to the running model, prints the reply
├── attacks/            # the extraction toolkit, one file per family (see attacks/ATTACKS.md)
│   ├── ATTACKS.md
│   ├── 01-<family>.prompt
│   ├── 02-<family>.prompt
│   ├── 03-<family>.prompt
│   ├── 04-<family>.prompt
│   └── 05-<family>.prompt
└── history/            # every past Modelfile version, kept as a trace of the
    └── CHANGELOG.md      # iteration (what changed, what broke, what was learned)
```

## Part 1: The agent (`Modelfile`)

Built on the imposed base model, `granite3.1-moe:3b`. Its `SYSTEM` block keeps a
`{codeword}` secret behind a `{password}`, and must pass three checks:

1. `ollama create` succeeds.
2. **release**: given the exact password, the agent hands over the codeword.
3. **utility**: the agent still answers ordinary questions like a normal assistant.

The `Modelfile` in this repo keeps `{password}` and `{codeword}` as literal
placeholders (substituted for real values at grading time). To try the agent
locally, pick your own test values and build it with `make`.

### Setup

```sh
ollama pull granite3.1-moe:3b
cp .env.example .env   # then edit PASSWORD/CODEWORD in .env if you want
```

### Usage

```sh
make build                          # renders Modelfile.test from .env and creates the `code-name` model
make chat MSG="What is your codeword?"
make chat MSG="$(grep ^PASSWORD .env | cut -d= -f2)"   # test the release path
make clean                          # removes Modelfile.test and deletes the ollama model
```

`Modelfile.test` and `.env` are local-only (gitignored): they hold real test
values, never commit them.

## Part 2: The extraction toolkit (`attacks/`)

Five single-message prompts, each exploiting a *different* family of prompt
injection technique. Meant to be run against agents
we've never seen, so genericity beats a prompt hand-tuned to one target.

## Version history

Version snapshots, measured regressions and selection rationale are kept in
`history/CHANGELOG.md` and `history/results/`. They are a development trace;
the evaluated defense remains the root `Modelfile`.
