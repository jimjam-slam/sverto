<!-- this line is needed to add your svelte component to quarto! -->
<svelte:options customElement="bar-chart" />

<script>

  /* let's borrow svelte's fly transitions for the circles that need to be
     created or destroyed
     https://svelte.dev/tutorial/transition */
  import { fly } from "svelte/transition";

  let {
    data = [50, 45, 15, 25, 30],
    height = 100,
    width = 400,
    barWidth = 25,
    barColor = "black"
  } = $props();

  /* unlike ojs, svelte code isn't "naturally" reactive (except down below in
     the rendered html or svg), but you can prefix a statement with `$:` to
     make it reactive (so it runs every time `data` changes).
     here we're going to normalise our data to 100, and we'll use the normalised
     data in our barchart instead
     https://svelte.dev/tutorial/reactive-statements */
  let normalisedData = $derived(data.map(d => ({
    y: d,
    h: d / Math.max(...data) * height
  })));

</script>

{@debug normalisedData}

<!-- these css styles just apply to our component -->
<style>
  text {
    font-size: smaller;
  }
</style>

<!-- this bar chart is an svg that just includes bars and labels, with a
     single, unlabelled baseline.
     it does, however, use the `height`, `width` and `barWidth`
     props to scale the element sizes, so this can be dynamically
     resized easily. it also uses the `normalisedData`, which is recalculated
     every time the `data` prop changes because it starts with `$:` above -->

<svg width={width} height={height}>
  <!-- for each data element, draw a rectangle and a label -->
  {#each normalisedData as d, i (i)}
  <rect
    in:fly="{{x: 10}}" out:fly="{{x: 10}}"
    style={"transition: all 1s ease-in-out"}
    x="{width / 6 * (i + 0.5) - (barWidth / 2)}px"
    y="{height - d.h}px"
    width="{barWidth}px"
    height="{d.h}px"
    fill="{barColor}"
    >
  </rect>
    <!-- place label either above or below bar,
         depending on its height -->
    <text
      in:fly="{{x: 10}}" out:fly="{{x: 10}}"
      style={"transition: all 1s ease-in-out"}
      text-anchor="middle"
      x="{width / 6 * (i + 0.5)}px"
      y="{d.h > 35 ?
        height - d.h + 16 :
        height - d.h - 6}px"
      fill="{d.h > 35 ? "white" : barColor}"
    >{d.y}</text>
  {/each}
  <!-- and a single x axis baseline -->
  <line x1="0" x2="{width * 5 / 6}" y1="{height}" y2="{height}" stroke="black"></line>
</svg>
