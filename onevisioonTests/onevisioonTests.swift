import Testing
@testable import onevisioon

struct onevisioonTests {
    @Test
    func healthScoreRange() async throws {
        let store = await MainActor.run { SoulJourneyStore() }
        let score = await MainActor.run { store.courseCompletionPercent }
        #expect((0...100).contains(score))
    }
}
    