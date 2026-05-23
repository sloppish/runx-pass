# runx-pass

A [Runx](https://github.com/sloppish/runx) plugin for [pass](https://www.passwordstore.org/) — the standard Unix password manager.

Fuzzy-search your password store entries, type or copy passwords and OTP codes, and generate new passwords — all from the Runx launcher.

## Commands

| Command                | Description                                   |
|------------------------|-----------------------------------------------|
| `pass`                 | Search and type a password                    |
| `pass-copy`            | Search and copy a password to clipboard       |
| `otp`                  | Search and type an OTP code                   |
| `otp-copy`             | Search and copy an OTP code to clipboard      |
| `pass-gen <args>`      | Generate a new password and type it           |
| `pass-gen-copy <args>` | Generate a new password and copy to clipboard |

`pass-gen` and `pass-gen-copy` forward arguments directly to `pass generate`.

## Configuration

| Key            | Default             | Description                                 |
|----------------|---------------------|---------------------------------------------|
| `store_dir`    | `~/.password-store` | Path to the password store                  |
| `result_limit` | `12`                | Maximum number of fuzzy-match results shown |

## Requirements

- [pass](https://www.passwordstore.org/) installed and configured
- [pass-otp](https://github.com/tadfisher/pass-otp) for OTP commands
