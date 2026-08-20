# Code Comments

Comments are in English, always. Two separate registers: **doc comments** (on exported API)
and **inline comments** (inside function bodies). Different rules for each.

## Default: write nothing

Inside function bodies the default is zero comments. A comment is an exception that must earn
its place. Before writing one, both gates must pass:

1. **Can this be said in code instead?** A better name, an extracted function, a named constant
   instead of a magic number, a type instead of a convention. If yes — do that, no comment.
2. **Is the comment at a different level of abstraction than the code?** If it restates what the
   lines do, it is noise. Delete it.

## What code cannot say

This list is exhaustive. If the comment you are about to write does not fall into one of these,
do not write it.

- **Why this way and not the obvious way** — the reasoning is not recoverable from the code.
- **What was rejected and why** — the next reader will try to "improve" this and reintroduce the
  bug. This is the highest-value comment there is; say the alternative out loud.
- **Working around an external bug** — library, browser, driver, protocol, upstream API. Without
  this the code looks pointless and gets cleaned up.
- **Deliberately unidiomatic code** — you broke the language's or the codebase's convention on
  purpose. Say why, or someone will "fix" it back.
- **An optimization** — why this is written the awkward way, and ideally what was measured.
  Otherwise the next reader simplifies it and returns the regression.
- **Non-obvious invariant or ordering** — why no nil check is needed, why these two calls cannot
  be swapped, what is guaranteed true at this point.
- **Units, bounds, zero-value semantics** — ms vs sec, inclusive vs exclusive, nil vs empty.
- **Domain knowledge** a reader cannot be assumed to have, where a wrong reading is likely:
  a formula, a spec rule, a business invariant.
- **Consequence warnings** — this is slow, this cannot run concurrently, do not log this (PII).
- **Non-local coupling** — "changing this needs a matching change in X". Only when the language
  genuinely cannot centralize it.
- **Operational context** — where this sits in the larger flow, when the file cannot show it
  because it must not know about its callers. Code cannot express this without breaking
  encapsulation; it is the one thing better names never fix.

## Hard limits (inline)

- **Maximum 2 lines** per comment. Longer means it is a design comment: move it to the top of
  the file or type, or cut it.
- **Never longer than the code it describes.**
- **More than one inline comment in a function is a signal**, not a style. Reconsider the code
  first; if it still needs two, fine, but do not write three.
- No end-of-line comments except in data tables and field declarations (units).

## Doc comments (exported API only)

Every exported symbol gets a doc comment, following the language convention. Here grammar is
strict: full sentence, capitalized, terminating period, third person, present tense.

- **Go**: start with the symbol name — `// Quote returns a double-quoted string literal.`
  Package comment starts with `// Package name ...`. Booleans: "reports whether".
  Document the zero value if it is not obvious, and concurrency guarantees if stronger
  than the default. Implementation details, algorithms and justifications do **not** belong
  in a doc comment — those go in inline comments.
- **Rust**: one-line summary in third person singular (`Returns`, not `Return`), then
  `# Examples`, `# Panics`, `# Errors`, `# Safety` as applicable.
- **Python**: summary line ≤ 80 chars ending in a period, then `Args:` / `Returns:` / `Raises:`.

**Package/module doc is the one place length is allowed.** It explains the point of the package
to someone importing it: what it is for, what it guarantees, what it deliberately does not do.
Still about the contract, never about the implementation.

Unexported/private symbols follow the inline rules: comment only the non-obvious.

## Voice

Doc comments: neutral and conventional, as above.

Inline comments: write like a colleague leaning over your shoulder, not like a style guide.
Lowercase start, no trailing period, sentence fragments are all fine. Be concrete — name the
actual number, the actual error, the actual system. Humor is allowed when it fits and still
carries information.

Never use these — they are the tell of machine-written prose:

- hedging preambles: "Note that", "It's important to note", "Generally speaking", "In many cases"
- the "not just X, but Y" construction
- vague abstraction: "for performance reasons", "to ensure correctness", "handle edge cases"
- restating the line below in longer words

```go
// bad  — restates the code
// increment the counter by one
counter++

// bad  — vague, says nothing
// round the value for correctness
cents := round(amount)

// good — concrete, unrecoverable from the code
// provider 400s on fractional cents, so round down and eat the dust
cents := floorCents(amount)

// good — names the rejected alternative
// can't use errgroup here, the driver's conn isn't goroutine-safe
for _, row := range rows { ... }
```

## Never write

- Ticket IDs, task keys, task titles, sprint or epic names.
- Internal project names, company names, or anything work-identifying — these repos may go public.
- `TODO`, `FIXME`, `HACK`, `XXX`. Do not leave unfinished work behind a tag. If something truly
  cannot be finished now, **stop and ask the user** what to do with it — do not decide alone and
  do not bury it in a comment.
- Commented-out code. Delete it; git has it.
- Decorative separators, ASCII banners, section headers made of `=====`.
- `@author`, dates, change history, "modified by". That is git's job.
- Boilerplate doc that only re-spells the signature of an unexported function.

## Links

Ticket links are not a substitute for an explanation and never the whole comment. One exception:
a serious, genuinely non-obvious hack whose full story is long (a long incident, a repro, a
discussion with tradeoffs). Then the comment explains the hack **self-sufficiently** on its own,
and the link is an appendix — "details in <link>". A reader who cannot open the link must still
understand why the code is like this.

Stable external references are always fine and often the best comment available: RFC and spec
numbers, standards, papers, algorithm names, upstream issue URLs. They do not rot when a tracker
is migrated.

## Editing existing code

Comments are part of the code you touch, and **every limit above is measured on the comment as it
ends up, not on the lines you added**. Extending an eight-line comment by two lines produces a
ten-line comment, not a two-line edit. "It was already long" is not an exemption — the moment your
diff touches it, its length is yours.

**The unit is the declaration you touched, not the lines you edited.** Change a function's body and
its doc comment is in your diff, even though you never typed on those lines. Same for a field whose
type you changed, a const whose value you changed, an interface you added a method to. Before
finishing, re-read the doc comment of every declaration your diff lands in and hold it to the limits
— that comment is now yours whether or not git colours it green.

So when your change needs an existing comment to say more:

- **Rewrite it whole.** Re-derive it from what the code does now and fit the result inside the
  limits. Appending a clause to something already over budget is how these grow to ten lines
  without anyone ever deciding to write a ten-line comment.
- **Read the file's other comments while you are in there.** Not to tidy them — to find the ones
  that talk about what you just changed. Two comments describing the same mechanism differently, or
  one that still describes the behaviour you just replaced, is a bug report about your own diff.
  Fix those, and say so.
- **A doc comment that has grown into a specification is in the wrong place.** Move the contract to
  the type or package doc, where length is allowed, and leave the symbol its one-sentence summary.

A comment inside your diff that has become wrong or stale must be updated or deleted — a lying
comment is worse than none. Beyond that, still do not sweep the file for comment noise: an
unrelated comment that is merely verbose belongs to someone else's diff.
