<script>
  import { blur } from "svelte/transition"
  import { extent } from "d3-array"
  import { scaleLinear, scaleSequential } from "d3-scale"
  import { interpolateYlGnBu, interpolateYlOrRd, select, axisLeft, axisBottom, format, tickFormat, formatLocale } from "d3"

  // should be an array of objects with:
  // year
  // value
  export let data = []
  export let valueSuffix = "°C"
  export let colourScheme = "cool" // or warm
  $: console.log(colourScheme)
  $: colourRamp = (colourScheme == "cool") ?
    interpolateYlGnBu :
    interpolateYlOrRd

  // dimensions bound to size of container
  let height = 500
  let width = 300

  // add padding to chart
  $: padX = [60, width - 10]
  $: padY = [height - 30, 10]

  $: xDomain = extent(data.map(d => d.year))
  $: yDomain = extent(data.map(d => d.value))

  // scales (flip the colours if they're cool)
  $: xScale = scaleLinear()
    .domain(xDomain)
    .range(padX)
  $: yScale = scaleLinear()
    .domain(yDomain)
    .range(padY)
  $: colourScale = scaleSequential()
    .domain(colourScheme == "cool" ? yDomain.reverse() : yDomain)
    .interpolator(colourRamp)

  // temperature formatter (for x-axis)
  const tempFormat = formatLocale({
    currency: ["", valueSuffix]
  });

  // axes
  let xAxisGroup
  let yAxisGroup
  $: select(xAxisGroup)
    .transition()
    .duration(500)
    .call(axisBottom(xScale).tickFormat(format(".0f")))
  $: select(yAxisGroup)
    .transition()
    .duration(500)
    .call(axisLeft(yScale).tickFormat(tempFormat.format("$.1f")))

</script>

<style>

  svg circle {
    transition:
      cx 0.5s ease-in-out,
      cy 0.5s ease-in-out,
      fill 0.5s ease-in-out;
  }

  #x-axis, #y-axis {
    font-family: system-ui, -apple-system;
    font-size: 14px;
  }


</style>

<main bind:clientHeight={height} bind:clientWidth={width}>
  <svg width={width} height={height}>

    <g>
      {#each data as { year, value } (year) }
      <!-- points go here-->
      <circle
        cx="{xScale(year)}px"
        cy="{yScale(value)}px"
        r="5"
        fill="{colourScale(value)}"
        in:blur={{ duration: 500 }}
        out:blur={{ duration: 500 }}
        >
      </circle>
      {/each}
    </g>
    <!-- trend line goes here -->
      
    <!-- axes goes here (is rendered imperatively above)-->
    <g bind:this={xAxisGroup} id="x-axis"
      style:transform="translateY({padY[0]}px)"
    />
    <g bind:this={yAxisGroup} id="y-axis"
      style:transform="translateX({padX[0]}px)"
    />
  </svg>
</main>

