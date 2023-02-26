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
let difficulty = 0.01 // fraction of tasks that should succeed

let threshold = Int(Double(duration) * difficulty)
print("Threshold is \(threshold)") // lower is more difficult

enum ParallelError: Error {
    case cancelled
}

let result = try await withThrowingTaskGroup(of: Int?.self) { group -> YourResult in
    
    var count = 0
    
    func newJob() {
        count += 1
        let thread = count
        _ = group.addTaskUnlessCancelled(priority: .userInitiated) {
            try Task.checkCancellation()
            print("started \(thread)")
            let result = (0...duration).shuffled().first!
            print("finished \(thread): \(result)")
            let succeeded = result < threshold
            return succeeded ? result : nil
        }
    }
    
    for _ in 1...maxConcurrentTasks {
        newJob()
    }
    
    for try await result in group {
        if let result = result {
            group.cancelAll()
            print("CANCELLED ALL")
            return result
        } else {
            newJob()
        }
    }
    
    throw ParallelError.cancelled
}

print("Found \(result)!")
