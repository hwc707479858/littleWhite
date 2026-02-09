import Foundation
import Testing
@testable import littleWhite

struct PhotoImportTests {
    @Test
    func selectsOnlyFirstPhotoItem() {
        let firstURL = URL(fileURLWithPath: "/tmp/first.jpg")
        let secondURL = URL(fileURLWithPath: "/tmp/second.jpg")
        let items = [
            PickedPhotoItem(localURL: firstURL, mimeType: "image/jpeg"),
            PickedPhotoItem(localURL: secondURL, mimeType: "image/png")
        ]

        let selected = PhotoImportSelectionProcessor().first(from: items)

        #expect(selected?.localURL == firstURL)
        #expect(selected?.mimeType == "image/jpeg")
    }

    @Test
    func mapsPickedPhotoToImportedReport() {
        let now = Date(timeIntervalSince1970: 123)
        let url = URL(fileURLWithPath: "/tmp/report.jpg")
        let item = PickedPhotoItem(localURL: url, mimeType: "image/jpeg")

        let report = ImportReportMapper().mapPhotoItem(item, importedAt: now)

        #expect(report.sourceType == .photo)
        #expect(report.mimeType == "image/jpeg")
        #expect(report.localURL == url)
        #expect(report.createdAt == now)
    }
}
