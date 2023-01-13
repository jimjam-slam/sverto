<!-- <svelte:options accessors /> -->

<script>
  import { fly } from "svelte/transition";

  // forget the webcomponent: let's take a dataset as a direct array!
  // it expects pairs
  export let data;
  $: console.log("Dataset prop:", data);

</script>

<!-- we use svelte's in/out transitions for entering and existing dom elements,
     and vanilla css transitions for retained elements that change -->
<svg>
  {#each data as d, i (i)}
    <circle
      in:fly="{{y: 100}}" out:fly="{{y: 100}}"
      style={"transition: all 1s ease-out"}
      cx={15 * i + "%"} cy="50%" r={d}
      fill="black"
       />
  {/each}
</svg>