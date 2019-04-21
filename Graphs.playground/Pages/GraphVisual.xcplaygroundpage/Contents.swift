import UIKit
import PlaygroundSupport

let WIDTH: Double = 450
let HEIGHT: Double = 450
let LINE_DRAW_SPEED: Double = 1
let POINT_INTERDISTANCE: Double = 40.0
let POLAR_DISPERSE_ANGLE: Double = 72.0
let POINT_RADIUS: Double = 6
let INFINITY: Double = Double.greatestFiniteMagnitude
let FRAME: CGRect = CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT)

struct SimpleEdge: Hashable {
    var from: Int
    var to: Int
}

class GraphVisual: UIView {
    var graph: Graph?
    var size: Int = 5
    var lineLayer: UIView!, topLayer: UIView!
    var points: [CAShapeLayer] = []
    var drawnEdgeLines: CAShapeLayer?
    var coordinates: [CGPoint] = []
    
    init(frame: CGRect, size: Int) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.size = size
        
        self.lineLayer = UIView(frame: FRAME)
        self.lineLayer.backgroundColor = .clear
        self.insertSubview(lineLayer, at: 0)
        
        self.topLayer = UIView(frame: FRAME)
        self.topLayer.backgroundColor = .clear
        self.addSubview(topLayer)
        self.setupButtons()
        
        self.graph = Graph(setup: Graph.generateRandomGraph(size: size))
        self.points = drawPoints()
        self.drawLines(edges: self.graph?.edges ?? [])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButtons() {
        let primsButton = UIButton(type: .roundedRect)
        primsButton.frame = CGRect(x: WIDTH/2 - 40, y: HEIGHT*(9/10), width: 80, height: 30)
        primsButton.backgroundColor = UIColor.purple
        primsButton.setAttributedTitle(NSAttributedString(string: "Prims", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white]), for: .normal)
        primsButton.addTarget(self, action: #selector(startPrims), for: .touchUpInside)
        
        let resetButton = UIButton(type: .roundedRect)
        resetButton.frame = CGRect(x: WIDTH/2 - 140, y: HEIGHT*(9/10), width: 80, height: 30)
        resetButton.backgroundColor = UIColor.purple
        resetButton.setAttributedTitle(NSAttributedString(string: "Reset", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white]), for: .normal)
        resetButton.addTarget(self, action: #selector(resetGraph), for: .touchUpInside)
        
        let newGraph = UIButton(type: .roundedRect)
        newGraph.frame = CGRect(x: WIDTH/2 + 60, y: HEIGHT*(9/10), width: 80, height: 30)
        newGraph.backgroundColor = UIColor.purple
        newGraph.setAttributedTitle(NSAttributedString(string: "New", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white]), for: .normal)
        newGraph.addTarget(self, action: #selector(self.newGraph), for: .touchUpInside)
        
        self.addSubview(primsButton)
        self.addSubview(resetButton)
        self.addSubview(newGraph)
    }
    
    @objc func startPrims() {
        self.drawLines(edges: self.graph?.prims(start: 0) ?? [])
    }
    
    @objc func resetGraph() {
        self.drawLines(edges: self.graph?.edges ?? [])
    }
    
    @objc func newGraph() {
        self.graph = Graph(setup: Graph.generateRandomGraph(size: self.size))
        self.points = drawPoints()
        self.drawLines(edges: self.graph?.edges ?? [])
    }
    
    func getRectangularCoordinate(angle: Double, radius: Double) -> CGPoint {
        return CGPoint(
            x: radius * cos(angle * 0.0174533),
            y: radius * sin(angle * 0.0174533)
        )
    }
    
    func generateRandomPositions(averageRadius: Double, count: Int, canvas: CGRect) -> [CGPoint] {
        var positions: [CGPoint] = []
        var radius: Double = averageRadius, angleStep: Double = POLAR_DISPERSE_ANGLE
        var count: Int = count
        let xOrigin: Double = Double(canvas.width) / 2, yOrigin: Double = Double(canvas.height) / 2
        
        while(count > 0) {
            for degree in stride(from: 0, to: 360, by: angleStep) {
                guard count > 0 else { break }
                
                let polRadius = radius * Double.random(in: 0.85...1.15)
                let polDegree = degree * Double.random(in: 0.8...1.2)
                let point = getRectangularCoordinate(angle: polDegree, radius: polRadius)
                let position = CGPoint(x: Double(point.x) + xOrigin, y: Double(point.y) + yOrigin)
                
                positions.append(position)
                count -= 1
            }
            
            radius *= 2
            angleStep /= 2
        }
        
        return positions
    }
    
    func drawLines(edges: [Edge]) {
        var drawnEdges: Set<SimpleEdge> = Set<SimpleEdge>()
        var shapeEdge: [Edge] = []
        
        drawnEdgeLines?.removeFromSuperlayer()
        
        for edge in edges {
            let variationOne = SimpleEdge(from: edge.fromPoint, to: edge.toPoint)
            let variationTwo = SimpleEdge(from: edge.toPoint, to: edge.fromPoint)
            guard !drawnEdges.contains(variationOne) && !drawnEdges.contains(variationTwo) else {
                continue
            }
            
            shapeEdge.append(edge)
            drawnEdges.insert(variationOne)
        }
        
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath()
        var totalDisplayTime: Double = 0
        for edge in shapeEdge {
            path.move(to: coordinates[edge.fromPoint])
            path.addLine(to: coordinates[edge.toPoint])
            totalDisplayTime += Double(shapeEdge.count) * LINE_DRAW_SPEED * 0.4
        }
        print(totalDisplayTime)
        
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.path = path.cgPath

        self.lineLayer.layer.addSublayer(shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = Double(shapeEdge.count) * LINE_DRAW_SPEED * 0.4
        shapeLayer.add(animation, forKey: "MyAnimation")

        drawnEdgeLines = shapeLayer
    }
    
    func drawPoints() -> [CAShapeLayer] {
        let startAngle: CGFloat = 0
        let endAngle: CGFloat = 2 * CGFloat.pi
        
        for shape in self.points {
            shape.removeFromSuperlayer()
        }
        
        var points: [CAShapeLayer] = []
        self.coordinates = self.generateRandomPositions(averageRadius: POINT_INTERDISTANCE, count: self.graph!.adjacencyList.count, canvas: FRAME)
        
        for coordinate in coordinates {
            let pointShape = CAShapeLayer()
            let center = coordinate
            let circularPath = UIBezierPath(arcCenter: center, radius: CGFloat(POINT_RADIUS), startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            pointShape.path = circularPath.cgPath
            topLayer.layer.addSublayer(pointShape)
            points.append(pointShape)
        }
        
        return points
    }
}

let graph = GraphVisual(frame: FRAME, size: 20)
PlaygroundPage.current.liveView = graph

