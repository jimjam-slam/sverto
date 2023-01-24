<script>
  // let's borrow svelte's fly transitions for the circles that need to be
  // created or destroyed
  // https://svelte.dev/tutorial/transition
  // import { fly } from "svelte/transition";

  // here we declare `data` as a prop that this component can expect
  // https://svelte.dev/tutorial/declaring-props
  // export let data;

  // prefix a statement with $: to make it reactive (so it runs every time
  // data changes)
  // https://svelte.dev/tutorial/reactive-statements
  // $: console.log("Dataset prop:", data);

</script>

<style>
  svg text {
    fill: red;
  }
</style>

<!-- we use svelte's in/out transitions for entering and leaving dom elements,
     and vanilla css transitions for retained elements that change. the
     #each block means we create an svg <circle> for each element of data -->
<svg>
  <text x="50" y="50">Hello world!</text>
</svg>
