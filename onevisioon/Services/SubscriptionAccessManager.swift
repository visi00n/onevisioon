import Foundation
import Combine
import StoreKit

@MainActor
final class SubscriptionAccessManager: ObservableObject {
    private var updatesTask: Task<Void, Never>?
    private let billingPreviewMode = true
    private let testingFullAccessMode = true

    // Update these IDs to match App Store Connect products.
    private let monthlyProductID = "onevisioon.premium.monthly"
    private let yearlyProductID = "onevisioon.premium.yearly"
    private var subscriptionProductIDs: [String] { [monthlyProductID, yearlyProductID] }

    @Published private(set) var products: [Product] = []
    @Published private(set) var hasActiveSubscription = false
    @Published private(set) var previewSelectedVersion = "study"
    @Published private(set) var isInIntroTrial = false
    @Published private(set) var trialExpirationDate: Date?
    @Published private(set) var now = Date()
    @Published var isLoadingProducts = false
    @Published var isPurchasing = false
    @Published var errorMessage: String?

    var hasAccess: Bool {
        testingFullAccessMode || hasActiveSubscription || (billingPreviewMode && previewSelectedVersion == "premium")
    }

    var isPreviewModeActive: Bool {
        billingPreviewMode || testingFullAccessMode
    }

    var isMembershipEnabled: Bool {
        !testingFullAccessMode
    }

    var monthlyProduct: Product? {
        products.first(where: { $0.id == monthlyProductID })
    }

    var yearlyProduct: Product? {
        products.first(where: { $0.id == yearlyProductID })
    }

    var trialDaysRemaining: Int {
        guard let end = trialExpirationDate else { return 0 }
        let remainingSeconds = max(0, end.timeIntervalSince(now))
        return Int(ceil(remainingSeconds / 86_400.0))
    }

    func hasFreeTrialOffer(for product: Product) -> Bool {
        product.subscription?.introductoryOffer?.paymentMode == .freeTrial
    }

    init() {
        observeTransactionUpdates()

        Task {
            await refreshAccessState()
            await loadProducts()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func refreshAccessState() async {
        now = Date()
        guard !billingPreviewMode else {
            hasActiveSubscription = false
            isInIntroTrial = false
            trialExpirationDate = nil
            return
        }
        await refreshEntitlements()
    }

    func loadProducts() async {
        guard !billingPreviewMode else {
            products = []
            isLoadingProducts = false
            return
        }

        isLoadingProducts = true
        errorMessage = nil

        defer { isLoadingProducts = false }

        do {
            products = try await Product.products(for: subscriptionProductIDs)
                .sorted(by: { productSortRank(for: $0.id) < productSortRank(for: $1.id) })
        } catch {
            errorMessage = "Could not load subscription plans. Try again."
            products = []
        }
    }

    func startMonthlyTrial() async {
        guard isMembershipEnabled else {
            errorMessage = nil
            return
        }

        guard !billingPreviewMode else {
            errorMessage = "Billing is disabled in preview mode."
            return
        }

        errorMessage = nil

        if monthlyProduct == nil {
            await loadProducts()
        }

        guard let monthlyProduct else {
            errorMessage = "Monthly plan is unavailable. Try again in a moment."
            return
        }

        guard hasFreeTrialOffer(for: monthlyProduct) else {
            errorMessage = "A free trial is not configured for the monthly plan yet."
            return
        }

        await purchase(monthlyProduct)
    }

    func purchase(_ product: Product) async {
        guard isMembershipEnabled else {
            errorMessage = nil
            return
        }

        guard !billingPreviewMode else {
            errorMessage = "Billing is disabled in preview mode."
            return
        }

        isPurchasing = true
        errorMessage = nil

        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    errorMessage = "Purchase verification failed."
                    return
                }

                await transaction.finish()
                await refreshEntitlements()

            case .userCancelled:
                break

            case .pending:
                errorMessage = "Purchase is pending approval."

            @unknown default:
                errorMessage = "Unable to complete purchase."
            }
        } catch {
            errorMessage = "Purchase failed. Please try again."
        }
    }

    func restorePurchases() async {
        guard isMembershipEnabled else {
            errorMessage = nil
            return
        }

        guard !billingPreviewMode else {
            errorMessage = "Restore is disabled in preview mode."
            return
        }

        errorMessage = nil
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = "Restore failed. Try again in a moment."
        }
    }

    private func observeTransactionUpdates() {
        updatesTask = Task {
            guard !billingPreviewMode else { return }
            for await update in Transaction.updates {
                guard case .verified(let transaction) = update else { continue }
                await transaction.finish()
                await refreshEntitlements()
            }
        }
    }

    func setPreviewSelection(_ version: String) {
        let normalized = version == "premium" || version == "school" ? "premium" : "study"
        guard previewSelectedVersion != normalized else { return }
        previewSelectedVersion = normalized
    }

    func purchaseSelectedPlan(_ plan: String) async -> Bool {
        guard isMembershipEnabled else {
            errorMessage = nil
            return true
        }

        errorMessage = nil

        if products.isEmpty {
            await loadProducts()
        }

        let product: Product?
        switch plan {
        case "yearly":
            product = yearlyProduct
        default:
            product = monthlyProduct
        }

        guard let product else {
            errorMessage = "Bible School plans are unavailable right now. Double-check the product IDs in App Store Connect."
            return false
        }

        await purchase(product)
        return hasAccess
    }

    private func refreshEntitlements() async {
        now = Date()
        var active = false
        var trialActive = false
        var trialEnd: Date?

        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement else { continue }
            guard subscriptionProductIDs.contains(transaction.productID) else { continue }

            if let expirationDate = transaction.expirationDate {
                guard expirationDate > now else { continue }
            }

            active = true

            if transaction.offer?.type == .introductory {
                trialActive = true
                if let expiration = transaction.expirationDate {
                    if let existing = trialEnd {
                        trialEnd = max(existing, expiration)
                    } else {
                        trialEnd = expiration
                    }
                }
            }
        }

        hasActiveSubscription = active
        isInIntroTrial = trialActive
        trialExpirationDate = trialEnd
        now = Date()
    }

    private func productSortRank(for id: String) -> Int {
        if id == monthlyProductID { return 0 }
        if id == yearlyProductID { return 1 }
        return 99
    }
}
