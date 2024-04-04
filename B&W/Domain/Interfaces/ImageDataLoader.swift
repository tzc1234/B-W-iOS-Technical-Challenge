//
//  ImageDataLoader.swift
//  B&W
//
//  Created by Tsz-Lung on 04/04/2024.
//

import Foundation

protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    typealias Completion = (Result) -> Void
    
    func load(for url: URL, completion: @escaping Completion) -> Cancellable
}
