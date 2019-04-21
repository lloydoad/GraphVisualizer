# GraphVisualizer
A visualizer for minimal spanning tree generation methods

## Features
* Generating random graphs of specified size
* Visualizing all graph edges
<img src="https://github.com/lloydoad/GraphVisualizer/blob/master/images/createGraph.gif" width=250 height=250>
* Visualizing edges of minimal spanning tree and it's creation
<img src="https://github.com/lloydoad/GraphVisualizer/blob/master/images/createMST.gif" width=250 height=250>

## Graph Changes
### Graph Generation
``` swift
let SIZE: Int
```

## Style Changes
### Point Coordinates
Points are places by a semi random polar coordinate generation system. ```POINT_INTERDISTANCE``` changes distance between each concentric cycle of points and ```POLAR_DISPERSE_ANGLE``` changes angle between points within the same cycle. 
``` swift 
let POINT_INTERDISTANCE: Double { get, set }
let POLAR_DISPERSE_ANGLE: Double { get, set }
let POINT_RADIUS: Double { get, set }
```
**Note:** Distances and angles are multiplied by a random multiplier to reduce edge collisions and improve visibility.

### Canvas
``` swift 
let HEIGHT: Double { get, set }
let WIDTH: Double { get, set }
```

### Animation
``` swift 
let LINE_DRAW_SPEED: { get, set }
```
