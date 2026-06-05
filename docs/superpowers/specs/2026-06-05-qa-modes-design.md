# Q&A Modes Design

**Date:** 2026-06-05
**Status:** Approved

## Problem

The repo was originally structured around a log-first workflow (user installs something → Claude logs it → automate later). The user wants Claude to also serve as a knowledge assistant for two distinct question types:

1. **How-To questions** — "how do I do X?" → give commands immediately
2. **Advice questions** — "should I use X or Y?" → gather context, then pros/cons + recommendation

## Design

### Mode Detection (Option A)

Claude detects intent from phrasing:

| Pattern | Mode |
|---|---|
| "how do I...", "how to...", "what command...", "what's the syntax for..." | How-To |
| "should I...", "what's the best...", "X vs Y", "which is better...", "recommend..." | Advice |
| Ambiguous | Default to How-To, offer to compare alternatives |

### How-To Mode

- Answer immediately — no clarifying questions, no preamble
- Commands in code blocks, copy-paste ready
- One-line explanation only if non-obvious or has a gotcha
- Append "Want me to log this?" if it's something worth automating

### Advice Mode

1. Ask up to 3 context questions — one at a time, multiple-choice where possible
   - Focus on: hardware constraints, existing setup, workflow style, performance vs stability preference
2. Structured pros/cons per option
3. Clear recommendation with reasoning — no hedging, definitive pick

### Ambiguous Cases

Default to How-To (answer directly), then offer: "Want me to compare this against alternatives?"
