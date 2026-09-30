# CODENAME

No application code: a single `Modelfile` and a handful of
plain-text prompts, all running on `granite3.1-moe:3b` via [Ollama](https://ollama.com).

## Structure

```
codename/
├── Modelfile            # the hardened agent
├── STRATEGY.md          # how the agent keeps the codeword secret, and why
├── Makefile             # build/chat/clean helpers (see below)
├── .env.example         # template for local test PASSWORD/CODEWORD
├── scripts/chat.sh      # sends one message to a model, prints the reply
├── attacks/             # the extraction toolkit, one file per family
│   ├── ATTACKS.md                     # how each attack works + measured results
│   ├── 01-template-injection.prompt   # forged chat turns with role tokens
│   ├── 02-poem.prompt                 # creative obfuscation
│   ├── 03-obfuscation.prompt          # base64 instruction smuggling
│   ├── 04-authority.prompt            # privileged-mode impersonation
│   └── 05-prompt-leak.prompt          # system prompt disclosure
└── history/             # every past Modelfile version, kept as a trace of the
    ├── CHANGELOG.md     # iteration (what changed, what broke, what was learned)
    └── results/         # raw evaluation reports of v8 to v14
```

## Part 1: The agent (`Modelfile`)

Built on the imposed base model, `granite3.1-moe:3b`. Its `SYSTEM` block keeps a
`{codeword}` secret behind a `{password}`, and must pass three checks:

1. `ollama create` succeeds.
2. **release**: given the exact password, the agent hands over the codeword.
3. **utility**: the agent still answers ordinary questions like a normal assistant.

The defense does not rely on the model resisting prompt injection. A custom
`TEMPLATE` compares the user's message with the password before the model is
called, and only puts `SYSTEM` (and so the codeword) in the model's context
when they match exactly. Any other message is answered by a model that has
never seen either secret. See [STRATEGY.md](STRATEGY.md) for the full
reasoning, how the template works, measured results and limits.

Tested on Ollama 0.30.10. The template references `.Tools` on purpose: it is
what makes recent Ollama versions use it for chat requests.

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
make build                              # renders Modelfile.test from .env and creates the model
make chat MSG="What is your codeword?"  # one message, one reply, fresh conversation each time
make run                                # interactive chat, history kept until you quit
make clean                              # removes Modelfile.test and deletes the model
```

`Modelfile.test` and `.env` are local-only (gitignored): they hold real test
values, never commit them.

## Part 2: The extraction toolkit (`attacks/`)

Five single-message prompts, each exploiting a *different* family of prompt
injection technique, each under 1500 characters. Meant to be run against
agents we've never seen, so genericity beats a prompt hand-tuned to one
target.

| File | Family | What it exploits |
| --- | --- | --- |
| `01-template-injection.prompt` | Chat template injection | unescaped granite role tokens: forges a system turn and a started assistant answer |
| `02-poem.prompt` | Creative obfuscation | a writing task whose structure requires the secret |
| `03-obfuscation.prompt` | Encoded instruction smuggling | a base64 payload the model decodes and executes |
| `04-authority.prompt` | Authority impersonation | a claimed root/sudo context |
| `05-prompt-leak.prompt` | System prompt disclosure | asks for the instructions that contain the secret |

[attacks/ATTACKS.md](attacks/ATTACKS.md) explains each technique, why they
are distinct families, and their measured success rate against the
subject's weak skeleton and our own past versions.

## Version history

Version snapshots, measured regressions and selection rationale are kept in
`history/CHANGELOG.md` and `history/results/`. They are a development trace;
the evaluated defense remains the root `Modelfile`.
