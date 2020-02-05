[![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://swift.org)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](http://www.apple.com)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://github.com/Tapplion/XMLCoding/blob/master/LICENSE)

#  XMLCoding
Encoder &amp; Decoder for XML using Swift's `Codable` protocols.
This package is a fork of the original [ShawnMoore/XMLParsing](https://github.com/ShawnMoore/XMLParsing) including a modified version of [tadija/AEXML](https://github.com/tadija/AEXML) parser for reading and writing XML.

## Usage

### Read XML

Sample XML:
```xml
<?xml version="1.0" encoding="utf-8"?>
<note>
    <to>Bob</to>
    <from>Jane</from>
    <heading>Reminder</heading>
    <body>Do not forget to use XMLCoding!</body>
</note>
```

This is how you can use **XMLCoding** for working with this data, by first making a variable `data: Data` from the XML file:

```swift
guard let url = Bundle.main.url(forResource: "note", withExtension: "xml"),
    let data = try? Data(contentsOf: url) else { return nil }
```

Parse it by adding a custom initializer:

Sample `struct`:
```swift
struct Note {
    let to: String
    let from: String
    let heading: String
    let body: String
}

extension Note {
    init(from xmlElement: XMLElement) {
        to = xmlElement["to"].string
        from = xmlElement["from"].string
        heading = xmlElement["heading"].string
        body = xmlElement["body"].string
    }
}

guard let xmlDocument = try XMLDcoument(xml: data) else {
    return
}

let note = Note(from: xmlDocument.root)

// prints Note(to: "Bob", from: "Jane", heading: "Reminder", body: "Do not forget to use XMLCoding!")
print(note)
```

Or just make it conform to the `Decodable` protocol:

```swift
struct Note: Decodable {
    let to: String
    let from: String
    let heading: String
    let body: String
}

let decoder = XMLDecoder()
guard let note = try? decoder.decode(Note.self, from: data) else {
    return
}

// prints Note(to: "Bob", from: "Jane", heading: "Reminder", body: "Do not forget to use XMLCoding!")
print(note)
```
