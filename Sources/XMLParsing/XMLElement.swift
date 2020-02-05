//
//  https://github.com/Tapplion/XMLCoding
//  Copyright (c) Pascal Kimmel 2019-present
//  Licensed under the MIT license. See LICENSE file.
//

import Foundation

/**
 This is base class for holding XML structure.
 
 You can access its structure by using subscript like this: `element["foo"]["bar"]` which would
 return `<bar></bar>` element from `<element><foo><bar></bar></foo></element>` XML as an `XMLElement` object.
 */
open class XMLElement {
    
    // MARK: - Properties
    
    /// Every `XMLElement` should have its parent element instead of `XMLDocument` which parent is `nil`.
    open internal(set) weak var parent: XMLElement?
    
    /// Child XML elements.
    open internal(set) var children = [XMLElement]()
    
    /// XML Element name.
    open var name: String
    
    /// XML Element value.
    open var value: String?
    
    /// XML Element attributes.
    open var attributes: [String : String]
    
    /// Error value (`nil` if there is no error).
    open var error: XMLError?
    
    /// String representation of `value` property (if `value` is `nil` this is empty String).
    var string: String { return value ?? String() }
    
    /// Boolean representation of `value` property (`false` if `value` can't be represented as Bool).
    open var bool: Bool { return Bool(string) ?? false }
    
    /// Integer representation of `value` property (`zero` if `value` can't be represented as Integer).
    open var int: Int { return Int(string) ?? Int() }
    
    /// Double representation of `value` property (`zero` if `value` can't be represented as Double).
    open var double: Double { return Double(string) ?? Double() }
    
    // MARK: - Lifecycle
    
    /**
     Designated initializer - all parameters are optional.
     
     - parameter name: XML element name.
     - parameter value: XML element value (defaults to `nil`).
     - parameter attributes: XML element attributes (defaults to empty dictionary).
     
     - returns: An initialized `XMLElement` object.
     */
    public init(name: String, value: String? = nil, attributes: [String : String] = [String : String]()) {
        self.name = name
        self.value = value
        self.attributes = attributes
    }
    
    internal convenience init(name: String, includingValuesFrom object: NSObject) {
        self.init(name: name)
        
        if let dictionaryValue = object as? NSDictionary {
            addChildren(fromDictionary: dictionaryValue)
        } else if let arrayValue = object as? NSArray {
            addChildren(fromArray: arrayValue)
        }
    }

    // MARK: - XML Read
    
    /// The first element with given name **(Empty element with error if not exists)**.
    open subscript(key: String) -> XMLElement {
        guard let
            first = children.first(where: { $0.name == key })
            else {
                let errorElement = XMLElement(name: key)
                errorElement.error = XMLError.elementNotFound
                return errorElement
        }
        return first
    }
    
    /// Returns all of the elements with equal name as `self` **(nil if not exists)**.
    open var all: [XMLElement]? { return parent?.children.filter { $0.name == self.name } }
    
    /// Returns the first element with equal name as `self` **(nil if not exists)**.
    open var first: XMLElement? { return all?.first }
    
    /// Returns the last element with equal name as `self` **(nil if not exists)**.
    open var last: XMLElement? { return all?.last }
    
    /// Returns number of all elements with equal name as `self`.
    open var count: Int { return all?.count ?? 0 }
    
    /**
     Returns all elements with given value.
     
     - parameter value: XML element value.
     
     - returns: Optional Array of found XML elements.
     */
    open func all(withValue value: String) -> [XMLElement]? {
        let found = all?.compactMap {
            $0.value == value ? $0 : nil
        }
        return found
    }
    
    /**
     Returns all elements containing given attributes.
     
     - parameter attributes: Array of attribute names.
     
     - returns: Optional Array of found XML elements.
     */
    open func all(containingAttributeKeys keys: [String]) -> [XMLElement]? {
        let found = all?.compactMap { element in
            keys.reduce(true) { (result, key) in
                result && Array(element.attributes.keys).contains(key)
                } ? element : nil
        }
        return found
    }
    
    /**
     Returns all elements with given attributes.
     
     - parameter attributes: Dictionary of Keys and Values of attributes.
     
     - returns: Optional Array of found XML elements.
     */
    open func all(withAttributes attributes: [String : String]) -> [XMLElement]? {
        let keys = Array(attributes.keys)
        let found = all(containingAttributeKeys: keys)?.compactMap { element in
            attributes.reduce(true) { (result, attribute) in
                result && element.attributes[attribute.key] == attribute.value
                } ? element : nil
        }
        return found
    }
    
    /**
     Returns all descendant elements which satisfy the given predicate.
     
     Searching is done vertically; children are tested before siblings. Elements appear in the list
     in the order in which they are found.
     
     - parameter predicate: Function which returns `true` for a desired element and `false` otherwise.
     
     - returns: Array of found XML elements.
     */
    open func allDescendants(where predicate: (XMLElement) -> Bool) -> [XMLElement] {
        var result: [XMLElement] = []
        for child in children {
            if predicate(child) {
                result.append(child)
            }
            result.append(contentsOf: child.allDescendants(where: predicate))
        }
        return result
    }
    
    /**
     Returns the first descendant element which satisfies the given predicate, or nil if no such element is found.
     
     Searching is done vertically; children are tested before siblings.
     
     - parameter predicate: Function which returns `true` for the desired element and `false` otherwise.
     
     - returns: Optional XMLElement.
     */
    open func firstDescendant(where predicate: (XMLElement) -> Bool) -> XMLElement? {
        for child in children {
            if predicate(child) {
                return child
            } else if let descendant = child.firstDescendant(where: predicate) {
                return descendant
            }
        }
        return nil
    }
    
    /**
     Returns the first descendant element containing given value, or nil if no such element is found.
     
     Searching is done vertically; children are tested before siblings.
     
     - parameter value: Attribute Value to be found.
     
     - returns: Optional XMLElement.
     */
    open func firstDescendant(whereAttributesContain value: String) -> XMLElement? {
        for child in children {
            if child.attributes.contains(where: {($0.value.contains(value))}) {
                return child
            }
        }
        return nil
    }
    
    /**
     Indicates whether the element has a descendant satisfying the given predicate.
     
     - parameter predicate: Function which returns `true` for the desired element and `false` otherwise.
     
     - returns: Bool.
     */
    open func hasDescendant(where predicate: (XMLElement) -> Bool) -> Bool {
        return firstDescendant(where: predicate) != nil
    }
    
    // MARK: - XML Write
    
    /**
     Adds child XML element to `self`.
     
     - parameter child: Child XML element to add.
     
     - returns: Child XML element with `self` as `parent`.
     */
    @discardableResult open func addChild(_ child: XMLElement) -> XMLElement {
        child.parent = self
        children.append(child)
        return child
    }
    
    /**
     Adds child XML element to `self`.
     
     - parameter name: Child XML element name.
     - parameter value: Child XML element value (defaults to `nil`).
     - parameter attributes: Child XML element attributes (defaults to empty dictionary).
     
     - returns: Child XML element with `self` as `parent`.
     */
    @discardableResult open func addChild(name: String, value: String? = nil, attributes: [String : String] = [String : String]()) -> XMLElement {
        let child = XMLElement(name: name, value: value, attributes: attributes)
        return addChild(child)
    }
    
    /**
     Adds an array of XML elements to `self`.
     
     - parameter children: Child XML element array to add.
     
     - returns: Child XML elements with `self` as `parent`.
     */
    @discardableResult open func addChildren(_ children: [XMLElement]) -> [XMLElement] {
        children.forEach{ addChild($0) }
        return children
    }
    
    @discardableResult internal func addChild(name: String, withValuesFrom array: NSArray) -> XMLElement {
        let element = XMLElement(name: name)
        let objects = array.compactMap({ $0 as? NSObject })
        
        objects.forEach({
            let childElement = XMLElement(name: "Item")
            if let dictionaryValue = $0 as? NSDictionary {
                childElement.addChildren(fromDictionary: dictionaryValue)
            } else if let arrayValue = $0 as? NSArray {
                childElement.addChild(name: name, withValuesFrom: arrayValue)
            } else if let stringValue = $0 as? NSString {
                childElement.addChild(name: name, value: stringValue.description)
            } else if let numberValue = $0 as? NSNumber {
                childElement.addChild(name: name, value: numberValue.description)
            } else {
                childElement.addChild(name: name)
            }
            element.addChild(childElement)
        })
        
        return addChild(element)
    }
    
    @discardableResult internal func addChildren(fromArray array: NSArray) -> [XMLElement] {
        var children = [XMLElement]()
        let objects = array.compactMap({ $0 as? NSObject })
        
        objects.forEach({
            let childElement = XMLElement(name: "Item")
            if let dictionaryValue = $0 as? NSDictionary {
                childElement.addChildren(fromDictionary: dictionaryValue)
            } else if let arrayValue = $0 as? NSArray {
                childElement.addChild(name: name, withValuesFrom: arrayValue)
            } else if let stringValue = $0 as? NSString {
                childElement.addChild(name: name, value: stringValue.description)
            } else if let numberValue = $0 as? NSNumber {
                childElement.addChild(name: name, value: numberValue.description)
            } else {
                childElement.addChild(name: name)
            }
            children.append(childElement)
        })
        
        children.forEach{ addChild($0) }
        return children
    }
    
    @discardableResult internal func addChildren(fromDictionary dictionary: NSDictionary) -> [XMLElement] {
        var children = [XMLElement]()
        let objects: [(String, NSObject)] = dictionary.compactMap({
            guard let key = $0 as? String, let value = $1 as? NSObject else { return nil }
            return (key, value)
        })
    
        for (key, value) in objects {
            if let dictionaryValue = value as? NSDictionary {
                children += addChildren(fromDictionary: dictionaryValue)
            } else if let arrayValue = value as? NSArray {
                addChild(name: key, withValuesFrom: arrayValue)
            } else if let stringValue = value as? NSString {
                children.append(XMLElement(name: key, value: stringValue.description))
            } else if let numberValue = value as? NSNumber {
                children.append(XMLElement(name: key, value: numberValue.description))
            } else {
                children.append(XMLElement(name: key))
            }
        }
        
        children.forEach{ addChild($0) }
        return children
    }
    
    /// Removes child XML element with specified name from `self` if it exists.
    open func removeChild(withName name: String) {
        if let childIndex = children.firstIndex(where: { $0.name == name}) {
            children.remove(at: childIndex)
        }
    }
    
    /// Removes `self` from `parent` XML element.
    open func removeFromParent() {
        parent?.removeChild(self)
    }
    
    fileprivate func removeChild(_ child: XMLElement) {
        if let childIndex = children.firstIndex(where: { $0 === child }) {
            children.remove(at: childIndex)
        }
    }
    
    internal var flattened: [String: Any] {
        var result: [String: Any] = [:]
        
        for child in children {
            let childName = child.name
            
            if let value = child.value {
                result[childName] = value
            } else if !child.children.isEmpty {
                let childValues = child.children.compactMap{$0.value}
                if childValues.count > 0 {
                    result[childName] = childValues
                } else {
                    let flattenedChildren = child.children.map{ $0.flattened }
                    result[childName] = flattenedChildren
                }
            } else {
                result[childName] = nil
            }
        }
        
        return result
    }
    
    fileprivate var parentsCount: Int {
        var count = 0
        var element = self
        while let parent = element.parent {
            count += 1
            element = parent
        }
        return count
    }
    
    fileprivate func indent(withDepth depth: Int) -> String {
        var count = depth
        var indent = String()
        while count > 0 {
            indent += "\t"
            count -= 1
        }
        return indent
    }
    
    /// Complete hierarchy of `self` and `children` in **XML** escaped and formatted String
    open var xmlString: String {
        var xml = String()
        
        // open element
        xml += indent(withDepth: parentsCount - 1)
        xml += "<\(name)"
        
        if attributes.count > 0 {
            // insert attributes
            for (key, value) in attributes {
                xml += " \(key)=\"\(value.xmlEscaped)\""
            }
        }
        
        if value == nil && children.count == 0 {
            // close element
            xml += "/>"
        } else {
            if children.count > 0 {
                // add children
                xml += ">\n"
                for child in children {
                    xml += "\(child.xmlString)\n"
                }
                // add indentation
                xml += indent(withDepth: parentsCount - 1)
                xml += "</\(name)>"
            } else {
                // insert string value and close element
                xml += ">\(string.xmlEscaped)</\(name)>"
            }
        }
        
        return xml
    }
    
    /// Same as `xmlString` but without `\n` and `\t` characters
    open var xmlCompact: String {
        let chars = CharacterSet(charactersIn: "\n\t")
        return xmlString.components(separatedBy: chars).joined(separator: "")
    }
    
    /// Same as `xmlString` but with 4 spaces instead '\t' characters
    open var xmlSpaces: String {
        let chars = CharacterSet(charactersIn: "\t")
        return xmlString.components(separatedBy: chars).joined(separator: "    ")
    }
}

public extension String {
    
    /// String representation of self with XML special characters escaped.
    var xmlEscaped: String {
        // we need to make sure "&" is escaped first. Not doing this may break escaping the other characters
        var escaped = replacingOccurrences(of: "&", with: "&amp;", options: .literal)
        
        // replace the other four special characters
        let escapeChars = ["<" : "&lt;", ">" : "&gt;", "'" : "&apos;", "\"" : "&quot;"]
        for (char, echar) in escapeChars {
            escaped = escaped.replacingOccurrences(of: char, with: echar, options: .literal)
        }
        
        return escaped
    }
}
