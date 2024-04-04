//
//  XCTestCase+MemoryLeakTracking.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "\(String(describing: instance.self)) should have deallocated. Potential memory leak.",
                file: file,
                line: line)
        }
    }
}
