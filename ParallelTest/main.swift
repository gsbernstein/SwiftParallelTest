//
//  main.swift
//  ParallelTest
//
//  Created by Greg Bernstein on 2/25/23.
//

import Foundation

let result = try await withThrowingTaskGroup(of: Int.self) { group -> Int in
    
    func newJob(number: Int) {
        group.addTask(priority: .userInitiated) {
            print("starting \(number)")
            _ = (1...99999).shuffled().sorted()
            return number
        }
    }
    
    var count = 20
    
    for thread in 1...count {
        newJob(number: thread)
    }
    
    var done: Int = 0
    
    for try await thread in group {
        print("finished \(thread)")
        done += 1
        count += 1
        newJob(number: count)
    }
    
    return done
}

print("all \(result) done")
