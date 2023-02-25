//
//  main.swift
//  ParallelTest
//
//  Created by Greg Bernstein on 2/25/23.
//

import Foundation

typealias YourResult = Int

let maxConcurrentTasks = 20
let duration = 99999 // higher means longer tasks
let difficulty = 0.01 // percent of tasks that should succeed

let threshold = Int(Double(duration) * difficulty)
print("Threshold is \(threshold)")

let result = try await withThrowingTaskGroup(of: Int?.self) { group -> YourResult? in
    
    var count = 0
    var yourResult: YourResult?
    
    func newJob() {
        count += 1
        let thread = count
        group.addTask(priority: .userInitiated) {
            try Task.checkCancellation()
            print("started \(thread)")
            let result = (0...duration).shuffled().first!
            print("finished \(thread): \(result)")
            let succeeded = result < threshold
            return succeeded ? result : nil // lower is more difficult
        }
    }
    
    
    
    for _ in 1...maxConcurrentTasks {
        newJob()
    }
    
    
    for try await result in group {
        if let result = result {
            yourResult = result
            group.cancelAll()
            print("CANCELLED ALL")
        } else {
            if yourResult == nil { newJob() }
        }
    }
    
    return yourResult
}

print("Found \(result!)!")
