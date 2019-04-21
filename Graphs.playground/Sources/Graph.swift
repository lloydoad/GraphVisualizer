import UIKit

//: - CONSTANTS
let WIDTH: Double = 500
let HEIGHT: Double = 500
let INFINITY: Double = Double.greatestFiniteMagnitude
let FRAME: CGRect = CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT)

public class Edge: Comparable, CustomStringConvertible {
    public var description: String
    
    public var fromPoint: Int
    public var toPoint: Int
    public var weight: Double
    
    public init(fromPoint: Int, toPoint: Int, weight: Double) {
        self.fromPoint = fromPoint
        self.toPoint = toPoint
        self.weight = weight
        self.description = "(\(fromPoint),\(toPoint)) -> \(weight)"
    }
    
    public static func < (lhs: Edge, rhs: Edge) -> Bool {
        return lhs.weight < rhs.weight
    }
    
    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        return lhs.weight == rhs.weight
    }
}

public class Graph {
    public var edges: [Edge] = []
    public var adjacencyList: [Int:[Edge]] = [:]
    
    public init(setup: [[Double]]) {
        for row in 0..<setup.count {
            for col in 0..<setup[row].count {
                guard setup[row][col] >= 0 else { continue }
                
                let edge = Edge(fromPoint: row, toPoint: col, weight: setup[row][col])
                edges.append(edge)
                
                if adjacencyList[row] == nil {
                    adjacencyList[row] = [edge]
                } else {
                    adjacencyList[row]?.append(edge)
                }
            }
        }
    }
    
    public static func generateRandomGraph(size: Int) -> [[Double]] {
        var matrix: [[Double]] = Array(repeating: Array(repeating: -1, count: size), count: size)
        
        for row in 0..<size {
            for col in row..<size {
                guard col + 1 < size else {continue}
                if((Int.random(in: 0...Int.max) % 2) == 1) {
                    let weight = Double.random(in: 0...10)
                    matrix[row][col] = weight
                    matrix[col][row] = weight
                }
            }
        }
        
        return matrix
    }
    
    public func prims(start: Int) -> [Edge] {
        guard start < self.adjacencyList.count else {
            return []
        }
        
        var current: Int = start
        var result: [Edge] = [], sorted: [Edge] = []
        var visited: [Bool] = Array.init(repeating: false, count: self.adjacencyList.count)
        var unvisited: Set<Int> = Set<Int>()
        
        self.adjacencyList.keys.forEach {unvisited.insert($0)}
        
        visited[current] = true
        unvisited.remove(current)
        self.adjacencyList[current]?.forEach {sorted.append($0)}
        sorted.sort()
        
        while(!unvisited.isEmpty) {
            var selectedEdge: Edge
            
            repeat {
                if sorted.isEmpty { return result }
                selectedEdge = sorted.remove(at: 0)
                current = selectedEdge.toPoint
            } while(visited[current] == true)
            
            result.append(selectedEdge)
            
            visited[current] = true
            unvisited.remove(current)
            self.adjacencyList[current]?.forEach {sorted.append($0)}
            sorted.sort()
        }
        
        return result
    }
}
