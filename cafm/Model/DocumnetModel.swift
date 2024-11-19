//
//  DocumnetModel.swift
//  cafm
//
//  Created by ShitaRam on 31/08/24.
//

import Foundation
import ObjectMapper

class DocumentResponse: Mappable {
    var document: Document?

    required init?(map: Map) {}

    func mapping(map: Map) {
        document <- map["document"]
    }
}

class Document: Mappable {
    var id: Int?
    var name: String?
    var parentFolderId: Int?
    var files: [File]?
    var childFolders: [Folder]?

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        parentFolderId <- map["parentFolderId"]
        files <- map["files"]
        childFolders <- map["childFolders"]
    }
}

class File: Mappable {
    var originalFileName: String?
    var fileUrl: String?
    var id: Int?
    var name: String?
    var siteId: Int?
    var folderId: Int?
    var folderName: String?
    var fileBlobUrl: String?
    var fileVersion: Int?
    var source: String?
    var referenceNumber: String?
    var uploaderUserId: Int?
    var uploaderUserName: String?
    var uploadDate: String?
    var issueDate: String?
    var expiryDate: String?
    var reviewerUserId: Int?
    var reviewerUserName: String?
    var note: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        originalFileName <- map["originalFileName"]
        fileUrl <- map["fileUrl"]
        id <- map["id"]
        name <- map["name"]
        siteId <- map["siteId"]
        folderId <- map["folderId"]
        folderName <- map["folderName"]
        fileBlobUrl <- map["fileBlobUrl"]
        fileVersion <- map["fileVersion"]
        source <- map["source"]
        referenceNumber <- map["referenceNumber"]
        uploaderUserId <- map["uploaderUserId"]
        uploaderUserName <- map["uploaderUserName"]
        uploadDate <- map["uploadDate"]
        issueDate <- map["issueDate"]
        expiryDate <- map["expiryDate"]
        reviewerUserId <- map["reviewerUserId"]
        reviewerUserName <- map["reviewerUserName"]
        note <- map["note"]
    }
}

class Folder: Mappable {
    var id: Int?
    var name: String?
    var required: Bool?
    var status: String?
    
    init() {
        
    }
    
    init(id: Int, name: String, required: Bool, status: String) {
        self.id = id
        self.name = name
        self.required = required
        self.status = status
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        required <- map["required"]
        status <- map["status"]
    }
}


struct CreateFolderReq : Mappable {
    var folderName: String?
    var parentFolderId: String?
    var siteId: Int?
    var isStatutoryRegister: Bool?
    var folderId: Int?
    var required: Bool?
    var status: String?
    var siteDocumentsEntity: [String]?
    var siteEntity: String?
    
    // Required initializer for the Mappable protocol
    init?(map: Map) {}
    
    init(folderName: String, parentFolderId: String, siteId: Int, isStatutoryRegister: Bool?) {
        self.folderName = folderName
        self.parentFolderId = parentFolderId
        self.siteId = siteId
        self.isStatutoryRegister = isStatutoryRegister
    }

    // Mapping function to map JSON keys to properties
    mutating func mapping(map: Map) {
        folderName            <- map["folderName"]
        parentFolderId        <- map["parentFolderId"]
        siteId                <- map["siteId"]
        isStatutoryRegister   <- map["isStatutoryRegister"]
        folderId <- map["folderId"]
        required <- map["required"]
        status <- map["status"]
        siteDocumentsEntity <- map["siteDocumentsEntity"]
        siteEntity <- map["siteEntity"]
    }
}

struct FileUploadRequest: Mappable {
    var folderId: Int?
    var files: [FileRequest]?

    init?(map: Map) {}
    
    init() {
        
    }

    mutating func mapping(map: Map) {
        folderId <- map["folderId"]
        files    <- map["files"]
    }
}

struct FileRequest: Mappable {
    var id: Int?
    var name: String?
    var issueDate: String?
    var expiryDate: String?
    var uploadDate: String?
    var note: String?
    var fileVersion: Int?
    var siteId: Int?
    var originalFileName: String?
    var uploaderUserId: Int?
    var reviewerUserId: Int?
    var referenceNumber: String?
    var statutoryCategoryId: Int?

    init?(map: Map) {}
    
    init() {
        
    }

    mutating func mapping(map: Map) {
        id                <- map["id"]
        name              <- map["name"]
        issueDate         <- map["issueDate"]
        expiryDate        <- map["expiryDate"]
        uploadDate        <- map["uploadDate"]
        note              <- map["note"]
        fileVersion       <- map["fileVersion"]
        siteId            <- map["siteId"]
        originalFileName  <- map["originalFileName"]
        uploaderUserId    <- map["uploaderUserId"]
        reviewerUserId    <- map["reviewerUserId"]
        referenceNumber   <- map["referenceNumber"]
        statutoryCategoryId <- map["statutoryCategoryId"]
    }
}

struct FileUploadResponse: Mappable {
    var files: [UploadedFile]?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        files <- map["files"]
    }
}

struct UploadedFile: Mappable {
    var originalFileName: String?
    var fileUrl: String?
    var statutoryCategoryId: Int?
    var id: Int?
    var name: String?
    var siteId: Int?
    var folderId: Int?
    var folderName: String?
    var fileBlobUrl: String?
    var fileVersion: Int?
    var source: String?
    var referenceNumber: String?
    var uploaderUserId: Int?
    var uploaderUserName: String?
    var uploadDate: String?
    var issueDate: String?
    var expiryDate: String?
    var reviewerUserId: Int?
    var reviewerUserName: String?
    var note: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        originalFileName    <- map["originalFileName"]
        fileUrl             <- map["fileUrl"]
        statutoryCategoryId <- map["statutoryCategoryId"]
        id                  <- map["id"]
        name                <- map["name"]
        siteId              <- map["siteId"]
        folderId            <- map["folderId"]
        folderName          <- map["folderName"]
        fileBlobUrl         <- map["fileBlobUrl"]
        fileVersion         <- map["fileVersion"]
        source              <- map["source"]
        referenceNumber     <- map["referenceNumber"]
        uploaderUserId      <- map["uploaderUserId"]
        uploaderUserName    <- map["uploaderUserName"]
        uploadDate          <- map["uploadDate"]
        issueDate           <- map["issueDate"]
        expiryDate          <- map["expiryDate"]
        reviewerUserId      <- map["reviewerUserId"]
        reviewerUserName    <- map["reviewerUserName"]
        note                <- map["note"]
    }
}

class VersionHistoryResponse: Mappable {
    var files: [File]?

    required init?(map: Map) {
        // Initializer implementation if needed
    }

    func mapping(map: Map) {
        files <- map["files"]
    }
}

class FileResponseData: Mappable {
    var files: [File]?

    required init?(map: Map) {
        // Initializer implementation if needed
    }

    func mapping(map: Map) {
        files <- map["files"]
    }
}
