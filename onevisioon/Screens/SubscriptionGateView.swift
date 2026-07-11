import Foundation
import StoreKit
import SwiftUI

enum PremiumFeature: String, Identifiable {
    case glorify
    case lessons
    case greekSearch
    case greekStudy
    case greekBible
    case bibleNotes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .glorify:
            return "Glorify"
        case .lessons:
            return "Lessons"
        case .greekSearch:
            return "Greek Search"
        case .greekStudy:
            return "Greek Study"
        case .greekBible:
            return "Greek Bible"
        case .bibleNotes:
            return "Bible Notes"
        }
    }

    var message: String {
        switch self {
        case .glorify:
            return "Discover your gifts and build daily habits that glorify God."
        case .lessons:
            return "Open every available lesson, Freedom path, and chapter quest."
        case .greekSearch:
            return "Search Greek words by meaning, transliteration, or Strong’s number."
        case .greekStudy:
            return "Explore the Greek text, pronunciation, meaning, and grammar in context."
        case .greekBible:
            return "Read the Greek Old and New Testaments with original-language study tools."
        case .bibleNotes:
            return "Create, organize, and return to your Bible notes across the app."
        }
    }
}

struct SubscriptionGateView: View {
    @ObservedObject var accessManager: SubscriptionAccessManager
    let feature: PremiumFeature

    @Environment(\.dismiss) private var dismiss

    private let privacyURL = URL(string: "https://unovisioon.com/privacy-policy")!
    private let termsURL = URL(string: "https://unovisioon.com/terms")!

    init(
        accessManager: SubscriptionAccessManager,
        feature: PremiumFeature = .lessons
    ) {
        self.accessManager = accessManager
        self.feature = feature
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    heroCard
                    benefitsCard
                    purchaseCard

                    if let message = accessManager.errorMessage {
                        errorCard(message)
                    }

                    legalFooter
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("One Visioon Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(OVTheme.body(15))
                }
            }
            .task {
                await accessManager.refreshAccessState()
                await accessManager.loadProducts()
            }
            .onChange(of: accessManager.hasAccess) { _, hasAccess in
                if hasAccess {
                    dismiss()
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(OVTheme.gold)

            Text("Unlock \(feature.title)")
                .font(OVTheme.display(36))
                .foregroundStyle(OVTheme.midnight)
                .multilineTextAlignment(.center)

            Text(feature.message)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.72))
                .multilineTextAlignment(.center)

            if let product = accessManager.yearlyProduct {
                Text("Only $3/month")
                    .font(OVTheme.heading(24))
                    .foregroundStyle(OVTheme.midnight)

                Text("Billed yearly at \(product.displayPrice).")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.muted)
                    .multilineTextAlignment(.center)
            } else if accessManager.isLoadingProducts {
                ProgressView("Loading your local price…")
                    .font(OVTheme.body(13))
                    .tint(OVTheme.midnight)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            LinearGradient(
                colors: [OVTheme.lemon.opacity(0.58), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .premiumSurfaceCard(cornerRadius: 28)
    }

    private var benefitsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Everything in Premium")
                .font(OVTheme.heading(21))
                .foregroundStyle(OVTheme.ink)

            benefit("Greek Bible, word search, and contextual word study")
            benefit("Bible notes and saved study insights")
            benefit("Every available lesson, Freedom path, and quest")
            benefit("The complete Glorify experience")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .premiumSurfaceCard(cornerRadius: 22, fill: OVTheme.elevatedCard)
    }

    private var purchaseCard: some View {
        VStack(spacing: 12) {
            if let product = accessManager.yearlyProduct {
                Text("$3/month, billed yearly at \(product.displayPrice)")
                    .font(OVTheme.heading(18))
                    .foregroundStyle(OVTheme.ink)

                Text("Auto-renews once per year unless canceled at least 24 hours before renewal.")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.muted)
                    .multilineTextAlignment(.center)

                Button {
                    Task {
                        await accessManager.purchase(product)
                    }
                } label: {
                    Text(accessManager.isPurchasing ? "Completing purchase…" : "Continue — \(product.displayPrice)/year")
                        .font(OVTheme.heading(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(OVTheme.midnight)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(accessManager.isPurchasing)
                .opacity(accessManager.isPurchasing ? 0.7 : 1)
            } else if !accessManager.isLoadingProducts {
                Text("The yearly plan is unavailable right now.")
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))

                Button("Retry Loading Plan") {
                    Task { await accessManager.loadProducts() }
                }
                .font(OVTheme.heading(15))
                .foregroundStyle(OVTheme.midnight)
            }

            Button("Restore Purchases") {
                Task {
                    await accessManager.restorePurchases()
                }
            }
            .font(OVTheme.body(14))
            .foregroundStyle(OVTheme.midnight)
            .disabled(accessManager.isPurchasing)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .premiumSurfaceCard(cornerRadius: 22, fill: .white)
    }

    private var legalFooter: some View {
        VStack(spacing: 8) {
            Text("Payment is charged to your Apple Account when you confirm. You can manage or cancel the subscription in your App Store account settings.")
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.muted)
                .multilineTextAlignment(.center)

            HStack(spacing: 18) {
                Link("Privacy Policy", destination: privacyURL)
                Link("Terms of Use", destination: termsURL)
            }
            .font(OVTheme.body(12))
            .foregroundStyle(OVTheme.midnight)
        }
        .padding(.horizontal, 8)
    }

    private func benefit(_ title: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(OVTheme.gold)

            Text(title)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.78))
        }
    }

    private func errorCard(_ message: String) -> some View {
        Text(message)
            .font(OVTheme.body(13))
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func monthlyEquivalent(for product: Product) -> String {
        let monthlyPrice = product.price / Decimal(12)
        return monthlyPrice.formatted(product.priceFormatStyle)
    }
}

struct SubscriptionGateView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionGateView(accessManager: SubscriptionAccessManager())
    }
}
