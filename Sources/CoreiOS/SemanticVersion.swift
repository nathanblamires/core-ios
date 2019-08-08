//
//  SemanticVersion.swift
//  Sniffer
//
//  Created by Nathan Blamires on 3/8/19.
//  Copyright © 2019 nathanblamires. All rights reserved.
//

import Foundation

public struct SemanticVersion {

    // Details of how semantic versioning works at: https://semver.org/
    
    static private let versionDelimeter: Character = "."
    static private let prereleaseDelimeter: Character = "-"
    static private let metadataDelimeter: Character = "+"
    
    public let major: Int
    public let minor: Int
    public let patch: Int
    
    public let prerelease: String?
    public let metadata: String?

    public init(_ version: String) throws {
        
        let splitVersion = version.split(separator: Self.versionDelimeter).map { String($0) }
        guard splitVersion.count >= 3 else { throw Error.invalidVersionString }
        
        guard let major = Int(splitVersion[0]) else { throw Error.invalidVersionString }
        self.major = major
        
        guard let minor = Int(splitVersion[1]) else { throw Error.invalidVersionString }
        self.minor = minor
        
        let patchString = splitVersion[2].splitOnce(whereSeparator: { $0 == Self.prereleaseDelimeter || $0 == Self.metadataDelimeter })[0]
        guard let patch = Int(patchString) else { throw Error.invalidVersionString }
        self.patch = patch
        
        // prerelease
        let metadataIndex = version.firstIndex(where: { $0 == "+" })
        if let prereleaseIndex = version.firstIndex(where: { $0 == "-" }), (metadataIndex == nil || prereleaseIndex < metadataIndex!) {
            prerelease = version.splitOnce(separator: "-")[1].splitOnce(separator: "+").first.map { String($0) }
        } else {
            prerelease = nil
        }
        
        // metadata
        let splitOnceByPlus = version.splitOnce(separator: "+")
        if splitOnceByPlus.count == 2 {
            metadata = splitOnceByPlus.last
        } else {
            metadata = nil
        }
    }

    public var asString: String {
        var text = "\(major).\(minor).\(patch)"
        if let prerelease = prerelease {
            text += String(Self.prereleaseDelimeter) + prerelease
        }
        if let metadata = metadata {
            text += String(Self.metadataDelimeter) + metadata
        }
        return text
    }

    enum Error: Swift.Error {
        case invalidVersionString
    }
}

extension String {

    func splitOnce(whereSeparator isSeparator: ((Self.Element) -> Bool)) -> [String] {
        return split(maxSplits: 1, omittingEmptySubsequences: true, whereSeparator: isSeparator).map { String($0) }
    }
    
    func splitOnce(separator: Character) -> [String] {
        return split(maxSplits: 1, omittingEmptySubsequences: true, whereSeparator: { $0 == separator }).map { String($0) }
    }
}

// MARK: - Comparable, Codable

extension SemanticVersion: Comparable, Codable {

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return lhs.major < rhs.major ||
            (lhs.major == rhs.major && lhs.minor < rhs.minor) ||
            (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch) ||
            (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch && lhs.prerelease != nil && rhs.prerelease == nil)
    }
}
