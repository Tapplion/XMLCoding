//
//  https://github.com/Tapplion/XMLCoding
//  Copyright (c) Pascal Kimmel 2019-present
//  Licensed under the MIT license. See LICENSE file.
//

import Foundation

/**
 This class is inherited from `XMLElement` and has a few addons to represent **XML Document**.
 
 XML Parsing is also done with this object.
 */
open class XMLDocument: XMLElement {
    
    // MARK: - Properties
    
    /// Root (the first child element) element of XML Document **(Empty element with error if not exists)**.
    open var root: XMLElement {
        guard let rootElement = children.first else {
            let errorElement = XMLElement(name: "Error")
            errorElement.error = XMLError.rootElementMissing
            return errorElement
        }
        return rootElement
    }
    
    public let options: XMLOptions
    
    // MARK: - Lifecycle
    
    /**
     Designated initializer - Creates and returns new XML Document object.
     
     - parameter root: Root XML element for XML Document (defaults to `nil`).
     - parameter options: Options for XML Document header and parser settings (defaults to `XMLOptions()`).
     
     - returns: Initialized XML Document object.
     */
    public init(root: XMLElement? = nil, options: XMLOptions = XMLOptions()) {
        self.options = options
        
        let documentName = String(describing: XMLDocument.self)
        super.init(name: documentName)
        
        // document has no parent element
        parent = nil
        
        // add root element to document (if any)
        if let rootElement = root {
            _ = addChild(rootElement)
        }
    }
    
    /**
     Convenience initializer - used for parsing XML data (by calling `loadXMLData:` internally).
     
     - parameter xmlData: XML data to parse.
     - parameter options: Options for XML Document header and parser settings (defaults to `XMLOptions()`).
     
     - returns: Initialized XML Document object containing parsed data. Throws error if data could not be parsed.
     */
    public convenience init(xml: Data, options: XMLOptions = XMLOptions()) throws {
        self.init(options: options)
        try loadXML(xml)
    }
    
    /**
     Convenience initializer - used for parsing XML string (by calling `init(xmlData:options:)` internally).
     
     - parameter xmlString: XML string to parse.
     - parameter encoding: String encoding for creating `Data` from `xmlString` (defaults to `String.Encoding.utf8`)
     - parameter options: Options for XML Document header and parser settings (defaults to `XMLOptions()`).
     
     - returns: Initialized XML Document object containing parsed data. Throws error if data could not be parsed.
     */
    public convenience init(xml: String, encoding: String.Encoding = String.Encoding.utf8, options: XMLOptions = XMLOptions()) throws {
        guard let data = xml.data(using: encoding) else { throw XMLError.parsingFailed }
        try self.init(xml: data, options: options)
    }
    
    // MARK: - Parse XML
    
    /**
     Creates instance of `XMLStackParser` (private class which is simple wrapper around `XMLParser`)
     and starts parsing the given XML data. Throws error if data could not be parsed.
     
     - parameter data: XML which should be parsed.
     */
    open func loadXML(_ data: Data, options: XMLOptions = XMLOptions()) throws {
        children.removeAll(keepingCapacity: false)
        let xmlParser = XMLStackParser(document: self, data: data)
        try xmlParser.parse()
    }
    
    // MARK: - Override

    /// Override of `xml` property of `XMLElement` - it just inserts XML Document header at the beginning.
    open override var xmlString: String {
        var xml =  "\(options.documentHeader.xmlString)\n"
        xml += root.xmlString
        return xml
    }
    
    internal override var flattened: [String : Any] {
        return root.flattened
    }
}
