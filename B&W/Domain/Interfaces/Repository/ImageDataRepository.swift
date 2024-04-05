//
//  ImageDataRepository.swift
//  B&W
//
//  Created by Tsz-Lung on 05/04/2024.
//

import Foundation

protocol ImageDataRepository {
    typealias Result = Swift.Result<Data?, Error>
    typealias Completion = (Result) -> Void
    
    func fetchImageData(for url: URL, completion: @escaping Completion) -> Cancellable
}
