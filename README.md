# Sverto

**Sverto** is an extension for [Quarto](https://quarto.org) that lets you seamlessly write and include [Svelte](https://svelte.dev) components, like charts and other visuals, in your Quarto website.

Your Svelte components can seamlessly react to your ObservableJS code, making it quick and easy to build visuals that animate in response to [user inputs](https://observablehq.com/@observablehq/inputs?collection=@observablehq/inputs) or other changing data in your document.

## 💭 Why Sverto?

[Quarto](https://quarto.org) helps users build beautiful documents regardless of their language of choice, and it encourages data analysts and scientists to explore web visualisation by making JavaScript accessible and easy to use. It makes interactive visualisations intuitive to write, but animated visuals are still a challenge that require either dipping into a high-level JavaScript library or learning a lower-level one like [d3](https://d3js.org).

[Svelte](https://svelte.dev) is a framework for building web visualisations and apps in JavaScript. Svelte goes out of its way to make writing self-contained components, like charts, comfortable and intuitive. It has a great [playground environment](https://svelte.dev/repl/hello-world?version=3.55.1) for developing and testing components, but like many web frameworks, the experience is much more complex when you start developing locally.

_Sverto aims to make it as easy to use Svelte components in Quarto documents as it is to work on them in the Svelte REPL: just write a `.svelte` file, add it to a Quarto document, and Sverto should take care of the rest._

## 📋 Prerequisites

You'll need to install two things to run Sverto:

- [Quarto](https://quarto.org)
- [Node and the Node Package Manager (npm)](https://nodejs.org)

## ⚙️ Installation

Install the project extension using:

```
quarto use template jimjam-slam/sverto
```

Then run:

```
npm install
```

This will add the extension itself (which includes some project scripts) to the `_extension` folder, as well as a few other files.

> **Note:** Sverto depends on running [project pre-render scripts](https://quarto.org/docs/projects/scripts.html#pre-and-post-render), so you can't currently use it with single documents.

## 🎉 Use

### Step 1: add Svelte to your document

In the document frontmatter, add `sverto` to `filters`, and add one or more `.svelte` files to `sverto.use`:

```yaml
---
title: "My document"
filters: ["sverto"]
sverto:
  use:
    - example.svelte
---
```

### Step 2: bring your Svelte component to life

Use an [Observable JS](https://quarto.org/docs/interactive/ojs/) chunk to _construct_ your Svelte component.

````js
```{ojs}
myChart = new example.default({
  target: document.querySelector("#chart")
})
```

:::{#chart}
:::
````

- the `target` is where it will appear. This needs to be an existing part of the document — you can put a [Pandoc div](https://quarto.org/docs/authoring/markdown-basics.html#divs-and-spans) right after this code, or put one anywhere else on the page
- `example` is the file name of your Svelte component, without the file extension

### Step 3: make your component reactive 

If your component has `props` that allow it to change or transition in response to other OJS code, you can update them by assigning the prop directly.

For example, if we have a dataset called `myData` in OJS, and a year slider called `selectedYear`, we might change a prop called `chartData` whenever the user selects a new year like:

````js
```{ojs}
myChart.chartData = myData.filter(d => d.year == selectedYear)
```
````

> **Note:** `quarto preview` won't "live reload" when you modify your Svelte component—but if you modify and save the Quarto doc that imports it, that will trigger a re-render. You may need to hard reload the page in your browser to see the updated Svelte component.
> 
> If you want to quickly iterate on the Svelte component and you aren't too concerned about the rest of your Quarto doc, you might find the [Svelte Preview](https://marketplace.visualstudio.com/items?itemName=RafaelMartinez.svelte-preview) extension for VSCode handy.

## 📦 What's in the box?

When you use the Sverto template in a project, it creates some files for you:

* [`example.qmd`](./example.qmd): an example Quarto doc that uses a Svelte component
* [`Circles.svelte`](./Circles.svelte): an example Svelte visualisation
* [`package.json`](./package.json): this is used to keep track of the dependencies of your Svelte components. You should add this to version control.
* Once you've run `npm install`, there'll also be a `package-lock.json` and a `.luarc.json`. You should version control these too (although you oughtn't need to edit them manually). You don't need to touch the `node_modules` folder, either.

See [`example.qmd`](./example.qmd) to learn how to add Svelte components to your documents and the [Svelte tutorial](https://svelte.dev/tutorial/basics) to learn how to create them.

As well as the project format, Sverto ships with document formats (the default is `sverto-html`). If you need to change document options that would normally go under `format: html`, use `format: sverto-html` or `format-sverto-revealjs` instead.

## 🛍 Use other libraries in your Svelte component

If you want to refer to other JavaScript libraries in your Svelte component (like d3, for example), add them to the project using `npm install package1 [package2 ...]`. For example:

```
npm install d3-scale
```

## Use pre-compiled Svelte components

If you'd prefer to compile your own Svelte components instead of letting this extension do it, you can skip steps 1 and 2 and simply refer to the compiled bundle with, for example, `Component = import("Component.js")` in an OJS block.

> **Note:** you must compile the Svelte component to an ES6 bundle, and you must enable accessors when compiling if you want to be able to update them from OJS. Refer to `_extensions/sverto/rollup.config.js` for guidance on configuring Rollup to do this.

## ❓ Issues

If you have any problems with the extension, please feel free to [create an issue](https://github.com/jimjam-slam/sverto)!

Special thanks to [Carlos Scheidegger](https://github.com/cscheid) from [Posit](https://posit.co) for his time and guidance getting Sverto working!

