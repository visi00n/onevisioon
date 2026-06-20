import Foundation
import SwiftUI
import StoreKit

struct SubscriptionGateView: View {
    @ObservedObject var accessManager: SubscriptionAccessManager

    private var yearlyVsMonthlyDiscountPercent: Int? {
        guard let monthlyProduct = accessManager.monthlyProduct,
              let yearlyProduct = accessManager.yearlyProduct else {
            return nil
        }

        let monthlyYearCost = NSDecimalNumber(decimal: monthlyProduct.price).doubleValue * 12
        let yearlyCost = NSDecimalNumber(decimal: yearlyProduct.price).doubleValue
        guard monthlyYearCost > 0, yearlyCost > 0, yearlyCost < monthlyYearCost else {
            return nil
        }

        return Int(round((1 - (yearlyCost / monthlyYearCost)) * 100))
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
                        await accessManager.purchaseMonthlyPlan()
                    }
                } label: {
                    Text(monthlyActionTitle)
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
                    Text("Plans are unavailable right now. Configure `\(SubscriptionAccessManager.monthlyProductID)` and `\(SubscriptionAccessManager.yearlyProductID)` in StoreKit/App Store Connect.")
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
                                if product.id == SubscriptionAccessManager.yearlyProductID,
                                   let yearlyVsMonthlyDiscountPercent {
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

                if accessManager.shouldShowYearlySpecialOffer,
                   let specialOffer = accessManager.yearlySpecialOffer {
                    specialYearlyOfferButton(specialOffer)
                }
            }

            Text(planFootnote)
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

    private func specialYearlyOfferButton(_ offer: Product.SubscriptionOffer) -> some View {
        Button {
            Task {
                _ = await accessManager.purchaseYearlySpecialOffer()
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Special")
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.gold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(OVTheme.sand)
                        .clipShape(Capsule())
                    Text("Special Yearly Bible School")
                        .font(OVTheme.heading(18))
                        .foregroundStyle(OVTheme.ink)
                    Text("Special yearly offer. Apple confirms eligibility and final price before purchase.")
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.62))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(offer.displayPrice)/yr")
                        .font(OVTheme.heading(18))
                        .foregroundStyle(OVTheme.midnight)
                    Text("limited yearly rate")
                        .font(OVTheme.body(10))
                        .foregroundStyle(OVTheme.ink.opacity(0.45))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(OVTheme.gold.opacity(0.11))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(OVTheme.gold.opacity(0.45), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(accessManager.isPurchasing)
        .opacity(accessManager.isPurchasing ? 0.7 : 1)
    }

    private func subscriptionDetail(for product: Product) -> String {
        let isMonthly = product.id == SubscriptionAccessManager.monthlyProductID
        let isYearly = product.id == SubscriptionAccessManager.yearlyProductID

        if isMonthly {
            return "Renews monthly. Apple confirms the exact price before purchase."
        }

        if isYearly {
            return "Renews yearly. Apple confirms the exact price before purchase."
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
        if product.id == SubscriptionAccessManager.monthlyProductID { return "Monthly Bible School" }
        if product.id == SubscriptionAccessManager.yearlyProductID { return "Yearly Bible School" }
        return product.displayName
    }

    private func marketingPrice(for product: Product) -> String {
        if product.id == SubscriptionAccessManager.monthlyProductID {
            return "\(product.displayPrice)/mo"
        }
        if product.id == SubscriptionAccessManager.yearlyProductID {
            return "\(product.displayPrice)/yr"
        }
        return product.displayPrice
    }

    private func planBadge(for product: Product) -> String {
        if product.id == SubscriptionAccessManager.monthlyProductID {
            return "Bible School"
        }
        if product.id == SubscriptionAccessManager.yearlyProductID {
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

    private var monthlyActionTitle: String {
        if let monthlyProduct = accessManager.monthlyProduct,
           accessManager.hasFreeTrialOffer(for: monthlyProduct) {
            return "Start Bible School Trial"
        }

        return "Start Monthly Plan"
    }

    private var planFootnote: String {
        if let yearlyVsMonthlyDiscountPercent {
            return "Yearly saves \(yearlyVsMonthlyDiscountPercent)% versus paying monthly across the year. Cancel anytime from Apple ID settings."
        }

        return "Apple shows the final localized price before purchase. Cancel anytime from Apple ID settings."
    }
}

struct SubscriptionGateView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionGateView(accessManager: SubscriptionAccessManager())
    }
}
