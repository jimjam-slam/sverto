# sverto
Add Svelte visualisations to your Quarto documents

## 🛍 Prerequisites

- [Quarto](https://quarto.org)
- [Node and the Node Package Manager (npm)](https://nodejs.org)

## ⚙️ Installation

Install the project extension using:

```
quarto use template 360-info/sverto
```

This will add the extension itself (which includes some project scripts) to the `_extension` folder, as well as a few other files.

Then run:

```
npm install
```

This will install everything you need for your Svelte components to work to the `node_modules` folder. You won't need to touch this folder, and it doesn't need to go into version control. It'll also create a `package-lock.json`, which you _should_ version control.

## 🎉 Use

Here's the short version of adding Svelte components to your Quarto docs:

1. Add a list of Svelte components (eg. `Circles.svelte`) you want to add to your document frontmatter under `svelte`
2. Add a magic placeholder div to your document using the `.svelteimport` class and a [Quarto include](https://quarto.org/docs/authoring/includes.html) to the path to your Quarto doc, prefixed with `.sverto/`. For example:

    ````
    :::{.svelteimport}
    {{< include .sverto/example.qmd >}}
    :::
    ````

3. Add a target block for your visual and give it an `#id`
4. Instantiate the Svelte component with `myVisual = Component.default()` using some default props and your target block
5. Update the instantiated component with `myVisual.propName`
6. Render your Quarto project as usual with `quarto render` or `quarto preview`.

**To see this all in practice, check out [`example.qmd`](./example.qmd).**

## 📦 What's in the box?

* [`example.qmd`](./example.qmd): an example Quarto doc that uses a Svelte component
* [`Circles.svelte`](./Circles.svelte): an example Svelte visualisation
* [`package.json`](./package.json): this is used to keep track of the dependencies of your Svelte components. You should add this to version control.
* Once you've run `npm install`, there'll also be a `package-lock.json`. You should version control this too.

See [`example.qmd`](./example.qmd) to learn how to add Svelte components to your documents and the [Svelte tutorial](https://svelte.dev/tutorial/basics) to learn how to create them.

## 🛍 Use other libraries in your Svelte component

If you want to refer to other JavaScript libraries in your Svelte component (like d3, for example), add them to the project using `npm install package1 [package2 ...]`. For example:

```
npm install d3-scale
```

If you'd prefer to compile your own Svelte components instead of letting this extension do it, you can skip steps 1 and 2 and simply refer to the compiled bundle with, for example, `Circles = require("Circles.js")` in an OJS block.

You must compiled Svelte component to ES6 bundles, and you must enable accessors when compiling if you want to be able to update them from OJS.

## ❓ Issues

If you have any problems with the extension, please feel free to [create an issue](https://github.com/360-info/sverto)!
