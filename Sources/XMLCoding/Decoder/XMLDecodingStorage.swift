//
//  https://github.com/Tapplion/XMLCoding
//  Copyright (c) Pascal Kimmel 2019-present
//  Licensed under the MIT license. See LICENSE file.
//

import Foundation

// MARK: - Decoding Storage

internal struct _XMLDecodingStorage {
    // MARK: Properties
    
    /// The container stack.
    /// Elements may be any one of the XML types (String, [String : Any]).
    private(set) internal var containers: [Any] = []
    
    // MARK: - Initialization
    
    /// Initializes `self` with no containers.
    internal init() {}
    
    // MARK: - Modifying the Stack
    
    internal var count: Int {
        return self.containers.count
    }
    
    internal var topContainer: Any {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.last!
    }
    
    internal mutating func push(container: Any) {
        self.containers.append(container)
    }
    
    internal mutating func popContainer() {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        self.containers.removeLast()
    }
}
