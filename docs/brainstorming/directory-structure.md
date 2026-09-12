## Current Directory

.
├── cli.test.ts
├── cli.ts
├── git-api
│   ├── auth-user.test.ts
│   ├── create-octokit.test.ts
│   ├── create-octokit.ts
│   ├── read-config.test.ts
│   ├── read-config.ts
│   ├── refresh-access-token.test.ts
│   └── user-token.test.ts
└── snags.ts

## Future Directory

- git-api
- `snags.ts`: The endo point. This module depends on `cli.ts`.
- `cli.ts`: This module has the `snags` main command and sub command based on `commands` modules.
- `sub-command`
- `commond-modules`: The modules that are placed in this directory are
