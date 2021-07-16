# GitHub Action - Versionist

> Flexible CHANGELOG generation GitHub Action

This action is a wrapper around the [Versionist](https://github.com/product-os/versionist) project. It provides automatic [Semver versioning](https://semver.org/) and changelog generation.

The action itself is fully inspired by [tmigone/versionist](https://github.com/tmigone/versionist), only difference is that this action fully uses `versionist` instead of `balena-versionist`.  

The following actions are taken sequentially:
- Run `versionist`, which will update `CHANGELOG.md`, `VERSION`, `package.json` etc.
- Add a new commit to the working branch with the versioning changes
- Create a release tag corresponding to the new version
- Push changes and tags to master

## Usage
### Inputs
| Parameter | Description | Required | Default |
| ------------------- | ----- | ------ | ----- |
| `commit` | Commit changes to current branch and create tag | Y | `false` |
| `github_email` | GitHub email to use for commits. | If `commit = true` | N/A |
| `github_username` | GitHub username to use for commits. | If `commit = true` | N/A |
| `github_token` | A Personal Access Token for the GitHub service account. Preferably using GitHub Secrets | If `commit = true` | N/A |

### Outputs
| Parameter | Description |
| --------- | ----------- |
| `version` | The project's version after running versionist. |
| `updated` | Returns `true` if the version was bumped by versionist. |
