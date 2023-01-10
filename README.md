# svelte-quarto
Add Svelte visualisations to your Quarto documents

## Prerequisites

- [Quarto](https://quarto.org)
- [Node and the Node Package Manager (npm)](https://nodejs.org)

## Installation

Install the project extension using:

```
quarto use template 360-info/svelte-quarto 
```

This will add the extension itself (which includes some project scripts) to the `_extension` folder, as well as a few other files.

Then run:

```
npm install
```

This will install everything you need for your Svelte components to work to the `node_modules` folder. You won't need to touch this folder, and it doesn't need to go into version control. It'll also create a `package-lock.json`, which you _should_ version control.

## What's in the box?

* [`example.qmd`](./example.qmd): an example Quarto doc that uses a Svelte component;
* [`Circles.svelte`](./Circles.svelte): an example Svelte visualisation; and
* [`package.json`](./package.json): this is used to keep track of the dependencies of your Svelte components. You should add this to version control.

See [`example.qmd`](./example.qmd) to learn how to add Svelte components to your documents and the [Svelte tutorial](https://svelte.dev/tutorial/basics) to learn how to create them.

## Use

Render your Quarto project as you normally would, with commands like `quarto run` and `quarto preview`.

The extension will compile any `.svelte` files you reference in your Quarto docs, turning them into JavaScript modules (`.js`). Your rendered Quarto documents will be updated to point to the compiled JavaScript.

## Use other libraries in your Svelte visualisation

If you want to refer to other JavaScript libraries in your Svelte component (like d3, for example), add them to the project using `npm install package1 [package2 ...]`. For example:

```
npm install d3-scale
```

This will install the package to `node_modules` (so it can be found when you're rendering your project), and it will update your `package.json` and `package-lock.json`.

## Issues

If you have any problems with the extension, please feel free to [create an issue](https://github.com/360-info/svelte-quarto)!
