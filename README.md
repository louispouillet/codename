# CODENAME

No application code: a single `Modelfile` and a handful of
plain-text prompts, all running on `granite3.1-moe:3b` via [Ollama](https://ollama.com).

## Structure

```
codename/
├── Modelfile          # the hardened agent
└── attacks/            # the extraction toolkit, one file per family
    ├── 01-<family>.prompt
    ├── 02-<family>.prompt
    ├── 03-<family>.prompt
    ├── 04-<family>.prompt
    └── 05-<family>.prompt
```

## Part 1: The agent (`Modelfile`)

Built on the imposed base model, `granite3.1-moe:3b`. Its `SYSTEM` block keeps a
`{codeword}` secret behind a `{password}`, and must pass three checks:

1. `ollama create` succeeds.
2. **release**: given the exact password, the agent hands over the codeword.
3. **utility**: the agent still answers ordinary questions like a normal assistant.

```sh
ollama pull granite3.1-moe:3b
ollama create codename -f Modelfile
ollama run codename
```

## Part 2: The extraction toolkit (`attacks/`)

Five single-message prompts, each exploiting a *different* family of prompt
injection technique. Meant to be run against agents
we've never seen, so genericity beats a prompt hand-tuned to one target.
