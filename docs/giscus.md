# Giscus Setup

The site includes a Giscus comments partial. It stays inactive until the repository and category IDs are filled in `hugo.toml`.

## Repository

Use the standard GitHub Pages repository:

```text
WangHaowen99/WangHaowen99.github.io
```

## Prerequisites

- The repository must be public. Giscus comments will not work for visitors if the repository is private.
- You need admin or maintainer permissions for the repository.
- The GitHub CLI command requires `gh` installed and authenticated. Alternatively, enable Discussions in the GitHub web UI under repository Settings -> Features -> Discussions.
- The Giscus GitHub App must be installed for `WangHaowen99/WangHaowen99.github.io`.
- Verify or create an `Announcements` discussion category, preferably with the category type `Announcements`.

## Steps

1. Enable Discussions for the repository:

   ```bash
   gh repo edit WangHaowen99/WangHaowen99.github.io --enable-discussions
   ```

2. Verify or create the `Announcements` discussion category in the repository settings before using it in `giscus.app`.

3. Install or authorize the Giscus GitHub App for the repository:

   ```text
   https://github.com/apps/giscus
   ```

4. Open the Giscus configuration page:

   ```text
   https://giscus.app
   ```

5. Use these values. They should match the existing `hugo.toml` Giscus settings:

   ```text
   Repository: WangHaowen99/WangHaowen99.github.io
   Page discussions mapping: pathname
   Discussion category: Announcements
   Theme: Light
   Language: Chinese Simplified
   ```

   The remaining generated script values can stay as configured unless they are intentionally changed.

6. Copy the generated `data-repo-id` and `data-category-id` values into `hugo.toml`:

   ```toml
   [params.giscus]
   repoID = "COPY_REPO_ID_FROM_GISCUS"
   categoryID = "COPY_CATEGORY_ID_FROM_GISCUS"
   ```

7. Commit and push the updated config:

   ```bash
   git add hugo.toml
   git commit -m "config: enable giscus comments"
   git push
   ```

## Privacy And Security

- Enabling comments loads third-party JavaScript from `https://giscus.app`.
- Comments are stored as public GitHub Discussions.
- Visitors must authorize GitHub and Giscus to comment.

Until `repoID` and `categoryID` are configured, article pages show a short setup note instead of a broken comments widget.
