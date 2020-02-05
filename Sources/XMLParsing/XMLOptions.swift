//
//  https://github.com/Tapplion/XMLCoding
//  Copyright (c) Pascal Kimmel 2019-present
//  Licensed under the MIT license. See LICENSE file.
//

import Foundation

/// Settings used by `Foundation.XMLParser`
public struct XMLParserSettings {
    /// Parser reports the namespaces and qualified names of elements. (defaults to `false`)
    public var shouldProcessNamespaces = false
    
    /// Parser reports the prefixes indicating the scope of namespace declarations. (defaults to `false`)
    public var shouldReportNamespacePrefixes = false
    
    /// Parser reports declarations of external entities. (defaults to `false`)
    public var shouldResolveExternalEntities = false
    
    /// Parser should trim whitespace from text nodes. (defaults to `true`)
    public var shouldTrimWhitespace = true
}

/// Options used in `XMLDocument`
public struct XMLOptions {
    
    /// Values used in XML Document header
    public struct DocumentHeader {
        /// Version value for XML Document header (defaults to 1.0).
        public var version = 1.0
        
        /// Encoding value for XML Document header (defaults to "utf-8").
        public var encoding = "utf-8"
        
        /// Standalone value for XML Document header (defaults to "no").
        public var standalone = "no"
        
        /// XML Document header
        public var xmlString: String {
            return "<?xml version=\"\(version)\" encoding=\"\(encoding)\" standalone=\"\(standalone)\"?>"
        }
    }

    /// Values used in XML Document header (defaults to `DocumentHeader()`)
    public var documentHeader = DocumentHeader()
    
    /// Settings used by `Foundation.XMLParser` (defaults to `XMLParserSettings()`)
    public var parserSettings = XMLParserSettings()

    /// Designated initializer - Creates and returns default `XMLOptions`.
    public init() {}
}
