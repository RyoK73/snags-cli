---
Date: 2026-09-09
---

# Storage Design for the GitHub Access Token and Refresh Token on OS Keychain

## Context and Problem Statement

We need to determine how to manage GitHub tokens that using [keytar](https://github.com/atom/node-keytar).

## Considered Options

- Manage with a single entry
- Manage with double entries
- … <!-- numbers of options can vary -->

## Pros and Cons of the Options

### Manage with a Single Entry

e.g.

```ts
setPassword("snags-cli","github_auth",JSON.stringfy(
  {
  "access-token":{
    "value":"xxxx"
    "expiredAt":"YYYY-MM-DD"
  },
  "refresh-token":{
    "value":"xxxx"
    "expiredAt":"YYYY-MM-DD"
  }
}
))
```

- Good, because the CLI can read the access-token and refresh-token in a single write/read operation.
- Good, because it results in fewer lines of code than the double-entry approach.

<!-- use "neutral" if the given argument weights neither for good nor bad -->

### Manage with Double Entries

e.g.

```ts
setPassword(
  "snags-cli",
  "access-token",
  JSON.stringfy({ value: "xxx", expiredAt: "YYYY-MM-DD" }),
);
setPassword(
  "snags-cli",
  "refresh-token",
  JSON.stringfy({ value: "xxx", expiredAt: "YYYY-MM-DD" }),
);
```

- Good, because the process is simple.
- Bad, because it results in more line of code than the single-entry approach.
- …

## Decision Outcome

- Manage with a single entry.
