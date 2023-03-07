<script lang="ts">
  
  export let xPos = 0;
  export let width = 10;
  export let height = 0;
  export let fill = "black";
  export let label = "";

  const textXPos = xPos + (barWidth / 2)

</script>

<rect
  in:fly="{{x: 10}}" out:fly="{{x: 10}}"
  style={"transition: all 1s ease-out"}
  x="{xPos}px"
  y="{height - d.h}px"
  width="{barWidth}px"
  height="{d.h}px"
  fill="{fill}"
  >
</rect>
  <!-- place label either above or below bar,
        depending on its height -->
<text
  in:fly="{{x: 10}}" out:fly="{{x: 10}}"
  style={"transition: all 1s ease-out"}
  text-anchor="middle"
  x="{textXPos}px"
  y="{d.h > 35 ?
    height - d.h + 16 :
    height - d.h - 6}px"
  fill="{d.h > 35 ? "white" : barColor}"
  >
  {d.y}
</text>