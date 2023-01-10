<!-- <svelte:options accessors /> -->

<script>
  import { randomUniform, randomInt } from "d3-random";
  import { scaleSequential } from "d3-scale";
  import { interpolatePlasma } from "d3-scale-chromatic";
  import { fly } from "svelte/transition";

  // forget the webcomponent: let's take a dataset as a direct array!
  // it expects pairs
  export let data;
  $: console.log("Dataset prop:", data);

  /* i originally took the dataset as a string of "x1|r1,x2|r2,..." in
     order to leverage the webcomponent string props */
  // $: datasetArray = my_dataset.split(",").map(d => ({
  //   x: d.split("|")[0],
  //   r: d.split("|")[1]
  // }));

  let colourScale = scaleSequential(interpolatePlasma).domain([5, 25]);

</script>

<!-- we use svelte's in/out transitions for entering and existing dom elements,
     and vanilla css transitions for retained elements that change. we'll use
     d3's colour scale functions to map colour too -->
<svg>
  {#each data as d, i (d.x)}
    <circle
      in:fly="{{y: 100}}" out:fly="{{y: 100}}"
      style={"transition: all 1s ease-out"}
      cx={d.x + "%"} cy="50%" r={d.r}
      fill={colourScale(d.r)}
       />
  {/each}
</svg>