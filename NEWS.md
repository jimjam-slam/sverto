## Sverto 0.0.2

- Bump minimum Quarto version to 1.3.0.
- Fixes for compatibility with newer Quarto 1.3 pre-releases
  - Quarto's switch from Pandoc 2 to Pandoc 3 caused some issues with the way Sverto identifies Svelte import statements. This should no longer be a problem.
- We now take advantage of the improved `.quartoignore` functionality in Quarto 1.3 to:
  1. avoid copying the `docs` folder in with the project template; and
  2. include the `.gitignore` with the template

## 0.0.1

- Initial release
