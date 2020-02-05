//
//  https://github.com/Tapplion/XMLCoding
//  Copyright (c) Pascal Kimmel 2019-present
//  Licensed under the MIT license. See LICENSE file.
//

import Foundation

// MARK: - Encoding Storage and Containers

internal struct _XMLEncodingStorage {
    // MARK: Properties
    
    /// The container stack.
    /// Elements may be any one of the XML types (NSNull, NSNumber, NSString, NSArray, NSDictionary).
    private(set) internal var containers: [NSObject] = []
    
    // MARK: - Initialization
    
    /// Initializes `self` with no containers.
    internal init() {}
    
    // MARK: - Modifying the Stack
    
    internal var count: Int {
        return self.containers.count
    }
    
    internal mutating func pushKeyedContainer() -> NSMutableDictionary {
        let dictionary = NSMutableDictionary()
        self.containers.append(dictionary)
        return dictionary
    }
    
    internal mutating func pushUnkeyedContainer() -> NSMutableArray {
        let array = NSMutableArray()
        self.containers.append(array)
        return array
    }
    
    internal mutating func push(container: NSObject) {
        self.containers.append(container)
    }
    
    internal mutating func popContainer() -> NSObject {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.popLast()!
    }
}
