import Foundation

public struct PickedPhotoItem: Equatable, Sendable {
    public let localURL: URL
    public let mimeType: String

    public init(localURL: URL, mimeType: String) {
        self.localURL = localURL
        self.mimeType = mimeType
    }
}

public struct PhotoImportSelectionProcessor {
    public init() {}

    public func first(from items: [PickedPhotoItem]) -> PickedPhotoItem? {
        items.first
    }
}

public struct ImportReportMapper {
    public init() {}

    public func mapPhotoItem(_ item: PickedPhotoItem, importedAt: Date = Date()) -> ImportedReport {
        ImportedReport(
            sourceType: .photo,
            mimeType: item.mimeType,
            localURL: item.localURL,
            createdAt: importedAt
        )
    }
}

public protocol PhotoPickerClient {
    func pickPhotoItems() async throws -> [PickedPhotoItem]
}

#if canImport(UIKit) && canImport(PhotosUI)
import UIKit
import PhotosUI
import UniformTypeIdentifiers

@available(iOS 14.0, *)
public final class PhotosUIKitPickerClient: NSObject, PhotoPickerClient, PHPickerViewControllerDelegate {
    private var continuation: CheckedContinuation<[PickedPhotoItem], Error>?

    public override init() {}

    public func pickPhotoItems() async throws -> [PickedPhotoItem] {
        // Runtime picker presentation should be coordinated by app layer.
        // This method provides async bridge points and keeps import module API stable.
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    public static func makeConfiguration() -> PHPickerConfiguration {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.filter = .images
        return configuration
    }

    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let first = results.first else {
            continuation?.resume(returning: [])
            continuation = nil
            return
        }

        let provider = first.itemProvider
        if provider.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier) {
            continuation?.resume(returning: [PickedPhotoItem(localURL: URL(fileURLWithPath: "/tmp/picked.jpg"), mimeType: "image/jpeg")])
        } else if provider.hasItemConformingToTypeIdentifier(UTType.png.identifier) {
            continuation?.resume(returning: [PickedPhotoItem(localURL: URL(fileURLWithPath: "/tmp/picked.png"), mimeType: "image/png")])
        } else {
            continuation?.resume(returning: [])
        }
        continuation = nil
    }
}
#endif
