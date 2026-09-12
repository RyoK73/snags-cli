---
Date: 2026-09-09
---

# How to Handle the Expired GitHub Access Token

## Context and Problem Statement

Note: [GitHub OAuth returns the access token and refresh token.](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#step-3-app-polls-github-to-check-if-the-user-authorized-the-device)
The GitHub access token expires 8 hours after it is issued when the expiration option is enabled, so we need to refresh the access token with the refresh token.
The question is when to detect that it has expired and refresh it.

## Considered Options

- Refresh when the "expiredAt" property of GitHub access token has passed
- Refresh when GitHub API returns an error code
- {title of option 3}
- … <!-- numbers of options can vary -->

## Pros and Cons of the Options

### Refresh When the "expiredAt" Property of the GitHub Access Token Has Passed

- Good, because it removes an unnecesssary API call that would otherwise return a "401" response.
- Bad, because it is affected by the local clock drift, and unexpected cases. (e.g. User revoked access on GitHub website.)

<!-- use "neutral" if the given argument weights neither for good nor bad -->

### Refresh When GitHub API Returns an Error Code

Refresh the GitHub access token when REST API returns `401`.

- Good, because it is always triggerd correctly.
- Bad, because at least one API call is needed even if the access token has already expired.
- …

## Decision Outcome

Chosen option: both "Refresh When the "expiredAt" Property of the GitHub Access Token Has Passed" and "Refresh When GitHub API Returns an Error Code", because each options coveres the other's downsides.
