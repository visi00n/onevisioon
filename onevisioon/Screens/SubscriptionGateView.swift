import SwiftUI
import StoreKit

struct SubscriptionGateView: View {
    @ObservedObject var accessManager: SubscriptionAccessManager
    private let launchMonthlyPrice = 15
    private let launchYearlyPrice = 80

    private var yearlyVsMonthlyDiscountPercent: Int {
        Int(round((1 - (Double(launchYearlyPrice) / Double(launchMonthlyPrice * 12))) * 100))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    hero
                    if accessManager.isMembershipEnabled {
                        trialCard
                        plansCard
                        restoreRow
                    } else {
                        unlockedPreviewCard
                    }

                    if accessManager.isMembershipEnabled, let message = accessManager.errorMessage {
                        Text(message)
                            .font(OVTheme.body(14))
                            .foregroundStyle(.red)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Bible School")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                guard accessManager.isMembershipEnabled else { return }
                await accessManager.refreshAccessState()
                await accessManager.loadProducts()
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bible School")
                .font(OVTheme.display(42))
                .foregroundStyle(OVTheme.midnight)
            Text("Go deeper chapter by chapter")
                .font(OVTheme.heading(27))
                .foregroundStyle(OVTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
            Text("Bible School unlocks deeper chapter breakdowns, historical context, cross references, and chapter quests while Studying the Bible stays clean and useful on its own.")
                .font(OVTheme.body(16))
                .foregroundStyle(OVTheme.ink.opacity(0.74))
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var trialCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose your plan")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            if accessManager.isInIntroTrial {
                Text("Trial active. \(accessManager.trialDaysRemaining) day(s) remaining.")
                    .font(OVTheme.body(15))
                    .foregroundStyle(OVTheme.midnight)
            } else {
                Text("Studying the Bible is open for daily reading and reflection. Bible School is for people who want deeper teaching, history, guided paths, and chapter quests.")
                    .font(OVTheme.body(15))
                    .foregroundStyle(OVTheme.ink.opacity(0.75))

                VStack(alignment: .leading, spacing: 8) {
                    Text("What you get now")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight)

                    subscriptionBullet("Deeper chapter-by-chapter teaching")
                    subscriptionBullet("Historical setting and Scripture connections")
                    subscriptionBullet("Chapter quests for every lesson folder")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Coming next")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight)

                    subscriptionBullet("More guided books beyond James and Proverbs")
                    subscriptionBullet("Expanded progress and account features")
                    subscriptionBullet("A richer long-form Bible School library")
                }

                Button {
                    Task {
                        await accessManager.startMonthlyTrial()
                    }
                } label: {
                    Text("Start Bible School Trial")
                        .font(OVTheme.heading(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(OVTheme.midnight)
                        .clipShape(Capsule())
                }
                .disabled(accessManager.isPurchasing || accessManager.isLoadingProducts)
                .opacity((accessManager.isPurchasing || accessManager.isLoadingProducts) ? 0.7 : 1)
            }

            Text("20% of Bible School profits are intended to support church work and helping people, so the subscription does more than unlock app features.")
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.ink.opacity(0.58))
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [OVTheme.sky.opacity(0.48), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var unlockedPreviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bible School is open")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Billing is temporarily turned off in this build so you can test the full Bible School experience without hitting a paywall.")
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.75))

            VStack(alignment: .leading, spacing: 8) {
                Text("What you can test now")
                    .font(OVTheme.heading(14))
                    .foregroundStyle(OVTheme.midnight)

                subscriptionBullet("Deeper chapter-by-chapter teaching")
                subscriptionBullet("Historical setting and Scripture connections")
                subscriptionBullet("Chapter quests across the lesson folders")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Coming next")
                    .font(OVTheme.heading(14))
                    .foregroundStyle(OVTheme.midnight)

                subscriptionBullet("Live App Store plans when billing is turned back on")
                subscriptionBullet("More guided books beyond James and Proverbs")
                subscriptionBullet("Expanded account and sync features")
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [OVTheme.sky.opacity(0.48), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var plansCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bible School plans")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            if accessManager.isLoadingProducts {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 14)
            } else if accessManager.products.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plans are unavailable right now. Configure `onevisioon.premium.monthly` ($\(launchMonthlyPrice)) and `onevisioon.premium.yearly` ($\(launchYearlyPrice)) in StoreKit/App Store Connect.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.65))

                    Button("Retry Loading Plans") {
                        Task { await accessManager.loadProducts() }
                    }
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.midnight)
                }
            } else {
                ForEach(accessManager.products, id: \.id) { product in
                    Button {
                        Task {
                            await accessManager.purchase(product)
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(planBadge(for: product))
                                    .font(OVTheme.body(11))
                                    .foregroundStyle(OVTheme.gold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(OVTheme.sand)
                                    .clipShape(Capsule())
                                Text(planTitle(for: product))
                                    .font(OVTheme.heading(18))
                                    .foregroundStyle(OVTheme.ink)
                                Text(subscriptionDetail(for: product))
                                    .font(OVTheme.body(13))
                                    .foregroundStyle(OVTheme.ink.opacity(0.62))
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(marketingPrice(for: product))
                                    .font(OVTheme.heading(18))
                                    .foregroundStyle(OVTheme.midnight)
                                if product.id == "onevisioon.premium.yearly" {
                                    Text("\(yearlyVsMonthlyDiscountPercent)% lower than paying monthly")
                                        .font(OVTheme.body(11))
                                        .foregroundStyle(OVTheme.gold)
                                }
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(OVTheme.midnight.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(accessManager.isPurchasing)
                    .opacity(accessManager.isPurchasing ? 0.7 : 1)
                }
            }

            Text("Yearly saves \(yearlyVsMonthlyDiscountPercent)% versus paying monthly across the year. Cancel anytime from Apple ID settings.")
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.ink.opacity(0.55))
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var restoreRow: some View {
        HStack {
            Spacer()
            Button("Restore Purchases") {
                Task {
                    await accessManager.restorePurchases()
                }
            }
            .font(OVTheme.body(14))
            .foregroundStyle(OVTheme.midnight)
            Spacer()
        }
    }

    private func subscriptionDetail(for product: Product) -> String {
        let isMonthly = product.id == "onevisioon.premium.monthly"
        let isYearly = product.id == "onevisioon.premium.yearly"

        if isMonthly {
            return "Launch monthly plan for flexible access."
        }

        if isYearly {
            return "Best launch value before yearly pricing rises."
        }

        guard let period = product.subscription?.subscriptionPeriod else {
            return "Auto-renewing subscription"
        }

        let unit: String
        switch period.unit {
        case .day:
            unit = period.value == 1 ? "day" : "days"
        case .week:
            unit = period.value == 1 ? "week" : "weeks"
        case .month:
            unit = period.value == 1 ? "month" : "months"
        case .year:
            unit = period.value == 1 ? "year" : "years"
        @unknown default:
            unit = "period"
        }

        return "Renews every \(period.value) \(unit)"
    }

    private func planTitle(for product: Product) -> String {
        if product.id == "onevisioon.premium.monthly" { return "Monthly Bible School" }
        if product.id == "onevisioon.premium.yearly" { return "Yearly Bible School" }
        return product.displayName
    }

    private func marketingPrice(for product: Product) -> String {
        if product.id == "onevisioon.premium.monthly" {
            return "$\(launchMonthlyPrice)/mo"
        }
        if product.id == "onevisioon.premium.yearly" {
            return "$\(launchYearlyPrice)/yr"
        }
        return product.displayPrice
    }

    private func planBadge(for product: Product) -> String {
        if product.id == "onevisioon.premium.monthly" {
            return "Bible School"
        }
        if product.id == "onevisioon.premium.yearly" {
            return "Best value"
        }
        return "Bible School"
    }

    private func subscriptionBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(OVTheme.midnight)
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            Text(text)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.78))
        }
    }
}

struct SubscriptionGateView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionGateView(accessManager: SubscriptionAccessManager())
    }
}
