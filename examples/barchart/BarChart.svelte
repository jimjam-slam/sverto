<script>
  // let's borrow svelte's fly transitions for the circles that need to be
  // created or destroyed
  // https://svelte.dev/tutorial/transition
  import { fly } from "svelte/transition";

  // here we declare `data` as a prop that this component can expect
  // https://svelte.dev/tutorial/declaring-props
  // in this case we're expecting an array of up to 5 numbers as `data` and
  // the max chart height as `height`
  export let data =  [50, 45, 15, 25, 30];
  export let height = 100;
  export let width = 400;
  export let barWidth = 25;
  export let barColor = "black"

  // prefix a statement with $: to make it reactive (so it runs every time
  // data changes)
  // https://svelte.dev/tutorial/reactive-statements
  // here we're going to normalise our data to 100
  $: normalisedData = data.map(d => ({
    y: d,
    h: d / Math.max(...data) * height
  }));
  $: console.log(normalisedData);

</script>

<style>
  @import url('https://fonts.googleapis.com/css2?family=Public+Sans:wght@300&display=swap');

  text {
    font-family: "Public Sans";
    font-size: smaller;
  }
</style>

<!-- this bar chart's pretty simple: just bars and labels,
     with a single, unlabelled baseline.
     it does, however, use the `height`, `width` and `barWidth`
     props to scale the element sizes, so this can be dynamically
     resized easily -->

<svg width={width} height={height}>
  <!-- for each data element, draw a rectangle and a label -->
  {#each normalisedData as d, i (i)}
  <rect
    in:fly="{{x: 10}}" out:fly="{{x: 10}}"
    style={"transition: all 1s ease-out"}
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
      style={"transition: all 1s ease-out"}
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
