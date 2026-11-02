import Foundation

enum FinderMetadataError: LocalizedError {
    case readFailed(path: String, message: String)
    case writeFailed(path: String, message: String)
    case invalidLabelNumber(path: String, value: Int)

    var errorDescription: String? {
        switch self {
        case .readFailed(let path, let message):
            "Could not read Finder tags for \(path): \(message)"
        case .writeFailed(let path, let message):
            "Could not change Finder tags for \(path): \(message)"
        case .invalidLabelNumber(let path, let value):
            "Finder returned invalid colour number \(value) for \(path)."
        }
    }
}

enum FinderMetadata {
    static func readColours(at paths: [String]) throws -> [FinderColour] {
        try paths.map { path in
            let url = URL(fileURLWithPath: path)
            let values: URLResourceValues
            do {
                values = try url.resourceValues(forKeys: [.labelNumberKey, .tagNamesKey])
            } catch {
                throw FinderMetadataError.readFailed(
                    path: path,
                    message: error.localizedDescription
                )
            }

            let labelNumber = values.labelNumber ?? 0
            guard let colour = FinderColour(rawValue: labelNumber) else {
                throw FinderMetadataError.invalidLabelNumber(
                    path: path,
                    value: labelNumber
                )
            }
            return colour
        }
    }

    static func setColour(_ colour: FinderColour, at paths: [String]) throws {
        guard !paths.isEmpty else { return }

        let tagNames = colour == .none ? [] : [colour.finderTagValue]
        for path in paths {
            let url = URL(fileURLWithPath: path) as NSURL
            do {
                try url.setResourceValue(tagNames, forKey: .tagNamesKey)
            } catch {
                throw FinderMetadataError.writeFailed(
                    path: path,
                    message: error.localizedDescription
                )
            }
        }
    }
}
