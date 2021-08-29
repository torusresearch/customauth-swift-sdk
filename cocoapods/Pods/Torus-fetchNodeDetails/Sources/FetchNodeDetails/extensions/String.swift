//
//  String.swift
//  
//
//  Created by Shubham on 18/3/20.
//
import Foundation

// Used in error thrown from guard let
extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
