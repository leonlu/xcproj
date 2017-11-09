import Foundation

/// This is the element for listing build configurations.
public class XCBuildConfiguration: PBXObject, Hashable {
   
    // MARK: - Attributes
    
    /// The path to a xcconfig file
    public var baseConfigurationReference: String?
    
    /// A map of build settings.
    public var buildSettings: BuildSettings
    
    /// The configuration name.
    public var name: String
    
    // MARK: - Init
    
    /// Initializes a build configuration.
    ///
    /// - Parameters:
    ///   - reference: build configuration reference.
    ///   - name: build configuration name.
    ///   - baseConfigurationReference: reference to the base configuration.
    ///   - buildSettings: dictionary that contains the build settings for this configuration.
    public init(reference: String,
                name: String,
                baseConfigurationReference: String? = nil,
                buildSettings: BuildSettings = [:]) {
        self.baseConfigurationReference = baseConfigurationReference
        self.buildSettings = buildSettings
        self.name = name
        super.init(reference: reference)
    }
    
    public static func == (lhs: XCBuildConfiguration,
                           rhs: XCBuildConfiguration) -> Bool {
        return lhs.reference == rhs.reference &&
            lhs.baseConfigurationReference == rhs.baseConfigurationReference &&
            lhs.name == rhs.name &&
            NSDictionary(dictionary: lhs.buildSettings).isEqual(to: rhs.buildSettings)
    }
    
    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case baseConfigurationReference
        case buildSettings
        case name
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.baseConfigurationReference = try container.decodeIfPresent(.baseConfigurationReference)
        self.buildSettings = try container.decode([String: Any].self, forKey: .buildSettings)
        self.name = try container.decode(.name)
        try super.init(from: decoder)
    }
    
}

// MARK: - XCBuildConfiguration Extension (PlistSerializable)

extension XCBuildConfiguration: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(XCBuildConfiguration.isa))
        dictionary["name"] = .string(CommentedString(name))
        dictionary["buildSettings"] = buildSettings.plist()
        if let baseConfigurationReference = baseConfigurationReference {
            let filename = proj.fileName(fileReference: baseConfigurationReference)
            dictionary["baseConfigurationReference"] = .string(CommentedString(baseConfigurationReference, comment: filename))
        }
        return (key: CommentedString(self.reference, comment: name), value: .dictionary(dictionary))
    }
    
}
