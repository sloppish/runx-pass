# runx-pass

A [Runx](https://github.com/sloppish/runx) plugin for [pass](https://www.passwordstore.org/) — the standard Unix password manager.

Fuzzy-search your password store entries, type or copy passwords and OTP codes, and generate new passwords — all from the Runx launcher.

## Commands

| Command                | Description                                   |
|------------------------|-----------------------------------------------|
| `pass`                 | Search and type a password                    |
| `pass-copy`            | Search and copy a password to clipboard       |
| `pass-otp`             | Search and type an OTP code                   |
| `pass-otp-copy`        | Search and copy an OTP code to clipboard      |
| `pass-gen <args>`      | Generate a new password and type it           |
| `pass-gen-copy <args>` | Generate a new password and copy to clipboard |

`pass-gen` and `pass-gen-copy` forward arguments directly to `pass generate`.

## Configuration

| Key            | Default             | Description                                 |
|----------------|---------------------|---------------------------------------------|
| `store_dir`    | `~/.password-store` | Path to the password store                  |
| `result_limit` | `12`                | Maximum number of fuzzy-match results shown |

## Aliases

You can define aliases for commands in your Runx plugin config, for example:

```toml
[plugin.pass.aliases]
pass = "p"
pass-otp = "otp"
# ...
```

This lets you type `p gmail` instead of `pass gmail`, etc.

## Requirements

- [pass](https://www.passwordstore.org/) installed and configured
- [pass-otp](https://github.com/tadfisher/pass-otp) for OTP commands
