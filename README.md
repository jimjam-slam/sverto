# quarto-svelte <img src="_extensions/quarto-svelte/quarto-svelte-logo.svg" align="right" width="180px" style="padding-left: 1rem;" />

**quarto-svelte** (formerly Sverto) is an extension for [Quarto](https://quarto.org) that lets you seamlessly write and include [Svelte](https://svelte.dev) components, like charts and other visuals, in your Quarto website.

Your Svelte components can seamlessly react to your [Observable JavaScript](https://quarto.org/docs/interactive/ojs/) code, making it quick and easy to build bespoke visuals that animate in response to [user inputs](https://observablehq.com/documentation/inputs/overview) or other changing data in your Quarto document.

Get going in four easy steps:

**Step 1: create a Svelte component**

If you've never written Svelte before, don't worry! You can start learning quickly with the comprehensive [Svelte tutorial](https://svelte.dev/tutorial/svelte/welcome-to-svelte).

quarto-svelte now uses a technique called [custom components](https://svelte.dev/docs/svelte/custom-elements) to bring Svelte into Quarto. So your Svelte component will need to start with a line like:

```html
<svelte:options customElement="my-circles" />
```

This name, `my-circles`, is what we'll use to place the component in our Quarto document. [It must be lowercase, and it must have at least one hyphen.](https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_custom_elements#registering_a_custom_element)

**Step 2: Add the Svelte file to your doc**

You can import your shiny new Svelte component into Quarto by adding the `quarto-svelte` filter and then including it (and any other Svelte files you want) as a list under `quarto-svelte.use`:

```yaml
---
filters:
  - quarto-svelte
quarto-svelte:
  use:
    - Circles.svelte
---
```

**Step 3: Place the Svelte component in your document**

Remember the name at the top of your Svelte file? To place your Svelte component, you're going to use that name as if it were an HTML tag:

````js
```{ojs}
myCircles = html`<my-circles></my-circles>`
```
````

**Step 4: To update your Svelte component, use accessors to give it new props**

If your Svelte component has [props](https://svelte.dev/tutorial/svelte/declaring-props) and you've assigned it to a variable in OJS, you can update the props on the fly! Let's update the data for our circles above:

````js
```{ojs}
myCircles.data = newData
```
````

## ⚙️ Installation

You'll need to install two things to run quarto-svelte:

- [Quarto](https://quarto.org)
- [Node and the Node Package Manager (npm)](https://nodejs.org)


Install the extension and required files using:

```
quarto use template jimjam-slam/quarto-svelte
```

> [!NOTE]
> If you're running quarto-svelte in a Quarto project, be sure to install it from the root, or top-level, project folder.
>
> Do not use `quarto add`: quarto-svelte includes a `package.json` file that must sit in your project or document folder. `quarto use template` will copy this file for you.

Then run:

```
npm install
```

This will add the extension itself (which includes some project scripts) to the `_extension` folder, as well as a few other files.

### 📦 What's in the box?

When you use the quarto-svelte template in a project, it creates some files for you:

* [`example.qmd`](./example.qmd): an example Quarto doc that uses a Svelte component
* [`Circles.svelte`](./Circles.svelte): an example Svelte visualisation
* [`package.json`](./package.json): this is used to keep track of the dependencies of your Svelte components. **You should add this to version control.**
* `package-lock.json` is created once you run `npm install`. You should add this to version control.
* `node_modules/`: This folder is created once you rum `npm install`. Don't add it to version control.

> [!NOTE]
> `quarto preview` won't "live reload" when you modify your Svelte component—but if you modify and save the Quarto doc that imports it, that will trigger a re-render. You may need to hard reload the page in your browser to see the updated Svelte component.
> 
> If you want to quickly iterate on the Svelte component, you might find the [Svelte Preview](https://marketplace.visualstudio.com/items?itemName=RafaelMartinez.svelte-preview) extension for VSCode handy.


## 🛍 Use other libraries in your Svelte component

If you want to refer to other JavaScript libraries in your Svelte component (like d3, for example), add them to the project using `npm install package1 [package2 ...]`. For example:

```
npm install d3
```

# 💭 Why quarto-svelte?

[Quarto](https://quarto.org) helps data scientists and analysts build beautiful documents regardless of their language of choice, and it encourages data analysts and scientists to explore web visualisation by making JavaScript accessible and easy to use.

Quarto makes interactive charts intuitive to write, but animated ones are still a challenge that require either dipping into a high-level JavaScript library or learning a lower-level one like [d3](https://d3js.org).

[Svelte](https://svelte.dev) is a framework for building charts, web visualisations and even apps in HTML, CSS and JavaScript. Svelte goes out of its way to make writing self-contained components, like charts, comfortable and intuitive.

Svelte has a great [playground environment](https://svelte.dev/repl) for developing and testing components, but like many web frameworks, the experience is much more complex when you start developing locally.

_quarto-svelte aims to make it as easy to build and use animated Svelte charts in Quarto documents as it is to work on them in the Svelte playground: just write a `.svelte` file, add it to a Quarto document, and quarto-svelte takes care of the rest._

## ❓ Issues

If you have any problems with the extension, please feel free to [create an issue](https://github.com/jimjam-slam/quarto-svelte)!

Special thanks to [Carlos Scheidegger](https://github.com/cscheid) from [Posit](https://posit.co) for his time and guidance getting quarto-svelte working!

