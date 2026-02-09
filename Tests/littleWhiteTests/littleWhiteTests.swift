import Testing
@testable import littleWhite

@Test
func formatDetectorSupportsExpectedMimeTypes() {
    #expect(SupportedReportFormat.detect(fromMimeType: "image/jpeg") == .jpeg)
    #expect(SupportedReportFormat.detect(fromMimeType: "image/png") == .png)
    #expect(SupportedReportFormat.detect(fromMimeType: "application/pdf") == .pdf)
}
