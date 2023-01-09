
import Foundation
import PathKit
import UniformTypeIdentifiers

public extension FileWrapper {
    enum FileType: String {
        case py
        case swift
        case json
    }
    
    
}

fileprivate extension FileWrapper {
    
    
    
    convenience init(_ p: PathKit.Path) throws {
        try self.init(url: p.url)
    }
    
    func files(ofType type: FileType) -> [FileWrapper] { files(ofType: type.rawValue) }
    
    func files(ofType type: String) -> [FileWrapper] {
        guard let fileWrappers = fileWrappers else { return [] }
        return fileWrappers.compactMap { k,v in
            if v.isRegularFile {
                if k.lowercased().contains(type) {
                    return v
                }
            }
            return nil
        }
    }
}

enum WrapPackageError: Error {
    // Throw when an invalid password is entered
    case noData
    
}

extension WrapPackageError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noData:
            return "No Data in File <WrapPackageError>"
        }
    }
}


public protocol WrapPackage {
    var sourceFiles: [FileWrapper] { get }
    var targetFiles: [FileWrapper] { get }
    var wrapPackage: FileWrapper? { get }
    var wrapPackageConfig: WrapPackageConfig? { get }
}
extension FileWrapper: WrapPackage {
    
    
    //var root: PathKit.Path?
    
    public var sourceFiles: [FileWrapper] {
        guard
            isDirectory,
            let fileWrappers = fileWrappers,
            let sources = fileWrappers.first(where: { k,_ in k == "sources" })?.value
        else { return [] }
        return sources.files(ofType: .py)
    }
    
    public var targetFiles: [FileWrapper] {
        guard
            let fileWrappers = fileWrappers,
            let sources = fileWrappers.first(where: { k,_ in k == "targets" })?.value
        else { return [] }
        return sources.files(ofType: .swift)
    }
    
    
    
    public var wrapPackage: FileWrapper? {
        guard
            isDirectory,
            let fileWrappers = fileWrappers,
            let pack = fileWrappers.first(where: { (key: String, value: FileWrapper) in
                key == "package.json"
            })
        else { return nil }
        return pack.value
    }
    
    public var wrapPackageConfig: WrapPackageConfig? {
        guard
            let data = regularFileContents,
            let config = try? JSONDecoder().decode(WrapPackageConfig.self, from: data)
        else { return nil }
        
        return config
    }
    
}


public class WrapPackageConfig: Codable {
    
    public let name: String
    
    public let depends: [String]
    
}

extension WrapPackageConfig {
    
}

