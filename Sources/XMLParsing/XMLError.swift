//
//  https://github.com/Tapplion/XMLCoding
//  Copyright (c) Pascal Kimmel 2019-present
//  Licensed under the MIT license. See LICENSE file.
//

import Foundation

/// A type representing error value that can be thrown or inside `error` property of `XMLElement`.
public enum XMLError: Error {
    /// This will be inside `error` property of `XMLElement` when subscript is used for not-existing element.
    case elementNotFound
    
    /// This will be inside `error` property of `XMLDocument` when there is no root element.
    case rootElementMissing
    
    /// `XMLDocument` can throw this error on `init` or `loadXMLData` if parsing with `XMLParser` was not successful.
    case parsingFailed
}
