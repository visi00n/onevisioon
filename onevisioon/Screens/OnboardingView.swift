import Foundation
import AuthenticationServices
import StoreKit
import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @ObservedObject var store: SoulJourneyStore
    @ObservedObject var accessManager: SubscriptionAccessManager
    @EnvironmentObject private var authManager: AuthSessionManager
    @Environment(\.requestReview) private var requestReview

    @State private var step: OnboardingStage = .welcome
    @State private var showReturningAccountSheet = false
    @State private var loadingMessageIndex = 0
    @State private var paywallMessage = ""

    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var age = ""
    @State private var country = ""
    @State private var usaAreaCode = ""
    @State private var gender = ""
    @State private var faithStage = ""
    @State private var currentSeason = ""
    @State private var currentStruggles: Set<String> = []
    @State private var biggestChallenge = ""
    @State private var lifeVision = ""
    @State private var desiredGrowth = ""
    @State private var behindArea = ""
    @State private var ifNothingChangesFeeling = ""
    @State private var futureStrength = ""
    @State private var weeklyCommitment = ""
    @State private var scriptureRhythm = ""
    @State private var prayerRhythm = ""
    @State private var learningStyle = ""
    @State private var supportNeed = ""
    @State private var spiritualStruggle = ""
    @State private var readinessResponse = ""
    @State private var reminderWindow = ""
    @State private var wantsNotifications = false
    @State private var referralCode = ""
    @State private var heardAboutSource = ""
    @State private var selectedMindsetGoal = ""
    @State private var selectedHealthGoal = ""
    @State private var selectedPurposeGoal = ""
    @State private var selectedCommunityGoal = ""
    @State private var selectedPremiumPlan = ""
    @State private var expandedGoalCategoryID: String? = "mindset"
    @FocusState private var isReferralFieldFocused: Bool
    @State private var isCountryPickerExpanded = false
    @State private var isAreaCodePickerExpanded = false

    private let loadingMessages = [
        "Reading your answers...",
        "Finding the best next steps...",
        "Matching Scripture to your needs...",
        "Getting your plan ready..."
    ]

    var body: some View {
        ZStack {
            sceneBackground

            VStack(spacing: 0) {
                if showsProgressBar {
                    quizProgressBar
                }

                currentStepView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        .onAppear {
            hydrateFromProfile(store.onboardingProfile)
        }
        .task(id: step) {
            await handleStepSideEffects()
        }
        .onChange(of: country) { _, _ in
            syncLocationPickers()
        }
        .fullScreenCover(isPresented: $showReturningAccountSheet) {
            ReturningAccountSheet(store: store) {
                completeReturningSignIn()
            }
            .environmentObject(authManager)
        }
    }
}

private extension OnboardingView {
    enum OnboardingStage: Int, CaseIterable, Identifiable {
        case welcome
        case quizIntro
        case greekCorrelation
        case gender
        case lifeState
        case latelyIssues
        case quizComplete
        case lifeVision
        case desiredGrowth
        case behindArea
        case oneYearFeeling
        case futureStrength
        case greatWork
        case cadence
        case supportNeed
        case spiritualStruggle
        case readiness
        case notifications
        case books
        case principles
        case referral
        case reviews
        case personalBasics
        case discovery
        case analysisLoading
        case analysisComplete
        case withOneVisioon
        case goals
        case futureIdentity
        case takeControl
        case systemBlueprint
        case membership

        var id: Int { rawValue }
    }

    struct Option: Identifiable, Hashable {
        let id: String
        let title: String
        let detail: String?

        init(_ title: String, detail: String? = nil) {
            self.id = title
            self.title = title
            self.detail = detail
        }
    }

    struct Testimonial: Identifiable {
        let id: String
        let name: String
        let subtitle: String
        let quote: String
        let assetName: String
    }

    struct BookHighlight: Identifiable {
        let id: String
        let title: String
        let author: String
        let quote: String
        let citation: String
        let accent: Color
    }

    struct GoalCategory: Identifiable {
        let id: String
        let title: String
        let options: [String]
    }

    var currentStepView: some View {
        Group {
            switch step {
            case .welcome:
                welcomeView
            case .quizIntro:
                quizIntroView
            case .greekCorrelation:
                greekCorrelationIntroView
            case .gender:
                singleChoiceQuestionView(
                    title: "What's your gender?",
                    subtitle: "Choose one.",
                    options: genderOptions,
                    selection: $gender
                )
            case .lifeState:
                singleChoiceQuestionView(
                    title: "Where are you with God right now?",
                    subtitle: "Choose the one that fits best.",
                    options: faithStageOptions,
                    selection: $faithStage
                )
            case .latelyIssues:
                multiChoiceQuestionView(
                    title: "What has been hard lately?",
                    subtitle: "Choose all that fit.",
                    options: currentStruggleOptions,
                    selection: $currentStruggles
                )
            case .quizComplete:
                scenicCheckpointView(
                    assetName: "bg3",
                    title: "Well done!",
                    subtitle: "You're setting yourself up for something better.",
                    buttonTitle: "Next >"
                )
            case .lifeVision:
                singleChoiceQuestionView(
                    title: "Who do you want to become with God's help?",
                    subtitle: "Choose one.",
                    options: lifeVisionOptions,
                    selection: $lifeVision
                )
            case .desiredGrowth:
                singleChoiceQuestionView(
                    title: "What do you need most right now?",
                    subtitle: "Choose one.",
                    options: desiredGrowthOptions,
                    selection: $desiredGrowth
                )
            case .behindArea:
                singleChoiceQuestionView(
                    title: "Where do you feel most behind?",
                    subtitle: "Choose one.",
                    options: behindAreaOptions,
                    selection: $behindArea
                )
            case .oneYearFeeling:
                singleChoiceQuestionView(
                    title: "If nothing changed this year, how would you feel?",
                    subtitle: "Choose one.",
                    options: oneYearFeelingOptions,
                    selection: $ifNothingChangesFeeling
                )
            case .futureStrength:
                singleChoiceQuestionView(
                    title: "If you were stronger in Christ, what would come more naturally?",
                    subtitle: "Choose one.",
                    options: futureStrengthOptions,
                    selection: $futureStrength
                )
            case .greatWork:
                scenicCheckpointView(
                    assetName: "bg4",
                    title: "Great Work!",
                    subtitle: "You're taking steps most people avoid.",
                    buttonTitle: "Next >"
                )
            case .cadence:
                singleChoiceQuestionView(
                    title: "How often do you want to work on your growth with God?",
                    subtitle: "Choose one.",
                    options: cadenceOptions,
                    selection: $weeklyCommitment
                )
            case .supportNeed:
                singleChoiceQuestionView(
                    title: "What would help you stay consistent?",
                    subtitle: "Choose one.",
                    options: supportNeedOptions,
                    selection: $supportNeed
                )
            case .spiritualStruggle:
                singleChoiceQuestionView(
                    title: "What are you struggling with most right now?",
                    subtitle: "Choose one.",
                    options: spiritualStruggleOptions,
                    selection: $spiritualStruggle
                )
            case .readiness:
                singleChoiceQuestionView(
                    title: "What do you want most from your next step?",
                    subtitle: "Choose one.",
                    options: readinessOptions,
                    selection: $readinessResponse
                )
            case .notifications:
                notificationsView
            case .books:
                booksView
            case .principles:
                principlesView
            case .referral:
                referralView
            case .reviews:
                reviewView
            case .personalBasics:
                basicsView
            case .discovery:
                singleChoiceQuestionView(
                    title: "How did you hear about us?",
                    subtitle: "Choose one.",
                    options: discoveryOptions,
                    selection: $heardAboutSource
                )
            case .analysisLoading:
                analysisLoadingView
            case .analysisComplete:
                analysisCompleteView
            case .withOneVisioon:
                withOneVisioonView
            case .goals:
                goalsView
            case .futureIdentity:
                futureIdentityView
            case .takeControl:
                takeControlView
            case .systemBlueprint:
                systemBlueprintView
            case .membership:
                membershipView
            }
        }
    }

    var sceneBackground: some View {
        OnboardingSceneBackground(
            assetName: backgroundAssetName(for: step),
            fallbackSeed: step.rawValue
        )
    }

    var progressStages: [OnboardingStage] {
        [
            .gender,
            .lifeState,
            .latelyIssues,
            .lifeVision,
            .desiredGrowth,
            .behindArea,
            .oneYearFeeling,
            .futureStrength,
            .cadence,
            .supportNeed,
            .spiritualStruggle,
            .readiness,
            .notifications,
            .referral,
            .personalBasics,
            .discovery,
            .analysisLoading,
            .analysisComplete,
            .withOneVisioon,
            .goals,
            .futureIdentity,
            .takeControl,
            .systemBlueprint,
            .membership
        ]
    }

    var hiddenProgressStages: Set<OnboardingStage> {
        [.welcome, .quizIntro, .greekCorrelation]
    }

    var showsProgressBar: Bool {
        !hiddenProgressStages.contains(step)
    }

    var progressValue: Double {
        guard let index = progressStages.firstIndex(of: step) else { return 0 }
        return Double(index + 1) / Double(progressStages.count)
    }

    var quizProgressBar: some View {
        VStack(spacing: 10) {
            Capsule()
                .fill(Color.white.opacity(0.1))
                .frame(height: 6)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(OVTheme.gold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .mask(alignment: .leading) {
                            GeometryReader { proxy in
                                Rectangle()
                                    .frame(width: proxy.size.width * progressValue)
                            }
                        }
                }
                .padding(.horizontal, 22)
                .padding(.top, 10)

            Spacer()
                .frame(height: 10)
        }
    }

    var welcomeView: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 118)

            VStack(spacing: 14) {
                Text("Welcome to One Visioon")
                    .font(OnboardingTypography.hero(34))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Get closer to God, understand the Bible, and build a stronger daily life.")
                    .font(OnboardingTypography.body(16, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 14) {
                GlowButton(
                    title: "BEGIN",
                    style: .fit,
                    action: { go(to: .quizIntro) }
                )

                Button {
                    showReturningAccountSheet = true
                } label: {
                    Text("I already have an account")
                        .font(OnboardingTypography.body(15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 22)
    }

    var quizIntroView: some View {
        ScenicIntroLayout(
            title: "Learning more about you",
            subtitle: "Answer each question honestly.",
            detail: "We use your answers to build a path that fits where you are and how we can guide you in God's Word.",
            buttonTitle: "Take the Quiz",
            assetName: "bg2",
            action: { go(to: .greekCorrelation) }
        )
    }

    var greekCorrelationIntroView: some View {
        ScenicIntroLayout(
            title: "Greek correlation Bible",
            subtitle: "Study the Word beneath the translation.",
            detail: "Tap Greek words inside verses to see meaning, transliteration, and deeper word study. Then follow where the same word appears again across Scripture so patterns, themes, and connections become easier to see.",
            buttonTitle: "Next >",
            assetName: "bg2",
            action: { go(to: .gender) }
        )
    }

    func scenicCheckpointView(
        assetName: String,
        title: String,
        subtitle: String,
        buttonTitle: String
    ) -> some View {
        ScenicIntroLayout(
            title: title,
            subtitle: subtitle,
            detail: nil,
            buttonTitle: buttonTitle,
            assetName: assetName,
            action: advance
        )
    }

    func singleChoiceQuestionView(
        title: String,
        subtitle: String,
        options: [Option],
        selection: Binding<String>,
        autoAdvance: Bool = true
    ) -> some View {
        Group {
            if autoAdvance {
                QuestionLayout(
                    title: title,
                    subtitle: subtitle,
                    canContinue: !selection.wrappedValue.isEmpty
                ) {
                    selectionOptions(options: options, selection: selection, autoAdvance: true)
                }
            } else {
                QuestionLayout(
                    title: title,
                    subtitle: subtitle,
                    buttonTitle: "Next >",
                    canContinue: !selection.wrappedValue.isEmpty,
                    action: advance
                ) {
                    selectionOptions(options: options, selection: selection, autoAdvance: false)
                }
            }
        }
    }

    @ViewBuilder
    func selectionOptions(
        options: [Option],
        selection: Binding<String>,
        autoAdvance: Bool
    ) -> some View {
        VStack(spacing: 12) {
            ForEach(options) { option in
                SelectionCard(
                    title: option.title,
                    detail: option.detail,
                    selected: selection.wrappedValue == option.title
                ) {
                    selection.wrappedValue = option.title
                    mirrorLegacyValuesIfNeeded(for: option.title)
                    if autoAdvance {
                        advanceAfterSelection(from: step)
                    }
                }
            }
        }
    }

    func multiChoiceQuestionView(
        title: String,
        subtitle: String,
        options: [Option],
        selection: Binding<Set<String>>
    ) -> some View {
        QuestionLayout(
            title: title,
            subtitle: subtitle,
            buttonTitle: "Next >",
            canContinue: !selection.wrappedValue.isEmpty,
            action: {
                biggestChallenge = primaryStruggleSummary
                advance()
            }
        ) {
            VStack(spacing: 12) {
                ForEach(options) { option in
                    SelectionCard(
                        title: option.title,
                        detail: option.detail,
                        selected: selection.wrappedValue.contains(option.title)
                    ) {
                        if selection.wrappedValue.contains(option.title) {
                            selection.wrappedValue.remove(option.title)
                        } else {
                            selection.wrappedValue.insert(option.title)
                        }
                    }
                }
            }
        }
    }

    var notificationsView: some View {
        QuestionLayout(
            title: "Stay consistent",
            subtitle: "We can send reminders so you keep showing up.",
            buttonTitle: "Allow",
            secondaryButtonTitle: "Don't Allow",
            canContinue: true,
            action: {
                Task {
                    let granted = await requestNotifications()
                    wantsNotifications = granted
                    reminderWindow = granted ? "enabled" : "disabled"
                    go(to: .referral)
                }
            },
            secondaryAction: {
                wantsNotifications = false
                reminderWindow = "disabled"
                go(to: .referral)
            }
        ) {
            VStack(alignment: .leading, spacing: 12) {
                FeatureCard(
                    title: "What this helps with",
                    lines: [
                        "Simple reminders to open the app",
                        "Help getting back on track",
                        "A steadier Bible routine"
                    ]
                )
            }
        }
    }

    var booksView: some View {
        InfoScrollLayout(
            title: "A few good books",
            subtitle: "These Christian books pair well with Scripture.",
            buttonTitle: "Next >",
            action: advance
        ) {
            VStack(spacing: 14) {
                ForEach(inspirationBooks) { book in
                    BookHighlightCard(book: book)
                }
            }
        }
    }

    var principlesView: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 58)

            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Simple")
                        .foregroundStyle(.white)
                    Text("Christ-centered wisdom")
                        .foregroundStyle(OVTheme.gold)
                    Text("can help you grow")
                        .foregroundStyle(.white)
                    Text("in faith and discipline.")
                        .foregroundStyle(OVTheme.gold)
                }
                .font(OnboardingTypography.hero(30))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 28)

                Text("Book references are here for inspiration.")
                    .font(OnboardingTypography.caption)
                    .foregroundStyle(Color.white.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                GlowButton(title: "Next >", action: advance)
            }
            .frame(maxWidth: .infinity, alignment: .top)

            Spacer(minLength: 32)
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 34)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    var referralView: some View {
        QuestionLayout(
            title: "Do you have a referral code?",
            subtitle: "You can skip this step.",
            buttonTitle: "Next >",
            canContinue: true,
            action: advance
        ) {
            VStack(alignment: .leading, spacing: 12) {
                TextField(
                    "",
                    text: $referralCode,
                    prompt: Text("Enter referral code")
                        .foregroundStyle(
                            isReferralFieldFocused
                                ? OVTheme.midnight.opacity(0.4)
                                : Color.white.opacity(0.38)
                        )
                )
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .font(OnboardingTypography.body(18, weight: .semibold))
                    .foregroundStyle(isReferralFieldFocused ? OVTheme.midnight : .white)
                    .focused($isReferralFieldFocused)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(isReferralFieldFocused ? Color.white : OnboardingColors.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                isReferralFieldFocused ? Color.white : OnboardingColors.border,
                                lineWidth: isReferralFieldFocused ? 1.4 : 1
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }

    var reviewView: some View {
        QuestionLayout(
            title: "What people are saying",
            subtitle: "A few early thoughts from people like you.",
            buttonTitle: "Next >",
            canContinue: true,
            action: advance
        ) {
            VStack(spacing: 14) {
                Button {
                    requestReview()
                } label: {
                    HStack(spacing: 10) {
                        Text("Rate One Visioon")
                            .font(OnboardingTypography.body(16, weight: .bold))
                            .foregroundStyle(.white)
                        StarRow()
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 15)
                    .background(OnboardingColors.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(OnboardingColors.goldBorder, lineWidth: 1.2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)

                ForEach(testimonials) { testimonial in
                    TestimonialCard(testimonial: testimonial)
                }
            }
        }
    }

    var basicsView: some View {
        QuestionLayout(
            title: "A little more about you",
            subtitle: "This helps us set up your path.",
            buttonTitle: "Next >",
            canContinue: !fullName.trimmed.isEmpty && !age.trimmed.isEmpty && !country.trimmed.isEmpty && (!usesUnitedStatesCountry || !usaAreaCode.trimmed.isEmpty),
            action: advance
        ) {
            VStack(spacing: 14) {
                OnboardingInputField(title: "Enter your name", text: $fullName)
                OnboardingInputField(
                    title: "Age",
                    text: $age,
                    keyboardType: .numberPad,
                    autocapitalization: .never
                )
                OnboardingPickerField(
                    title: "Country",
                    selection: $country,
                    isExpanded: $isCountryPickerExpanded,
                    options: countryOptions,
                    placeholder: "Select your country"
                )

                if usesUnitedStatesCountry {
                    OnboardingPickerField(
                        title: "Area code",
                        selection: $usaAreaCode,
                        isExpanded: $isAreaCodePickerExpanded,
                        options: areaCodeOptions,
                        placeholder: "Choose your 3-digit area code"
                    )
                }
            }
        }
    }

    var analysisLoadingView: some View {
        VStack(spacing: 18) {
            Spacer()
                .frame(height: 88)

            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.8)

            Text("Looking at your answers...")
                .font(OnboardingTypography.hero(30))
                .foregroundStyle(.white)

            Text(loadingMessages[loadingMessageIndex])
                .font(OnboardingTypography.body(15, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.82))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    var analysisCompleteView: some View {
        let score = potentialScore

        return InfoScrollLayout(
            title: "Analysis Complete",
            subtitle: "Here's what your answers are showing.",
            buttonTitle: "Next >",
            action: advance
        ) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(OVTheme.gold)

                Text("Based on your answers, you're living at about \(score)% of the focus, peace, and consistency you want right now.")
                    .font(OnboardingTypography.body(18, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                ComparisonBar(
                    title: "Where you are now",
                    value: Double(score) / 100.0,
                    accent: OVTheme.gold
                )

                ComparisonBar(
                    title: "Where you want to be",
                    value: 1.0,
                    accent: .white
                )

                Text("A lot of people start here, but you do not have to stay here.")
                    .font(OnboardingTypography.body(15, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                Text("*This result is an indication only, not a medical diagnosis.")
                    .font(OnboardingTypography.caption)
                    .foregroundStyle(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
    }

    var withOneVisioonView: some View {
        let currentScore = potentialScore

        return InfoScrollLayout(
            title: "What One Visioon can help you do",
            subtitle: "Clear next steps, steady Bible growth, and real progress with God.",
            buttonTitle: "Start your journey!",
            action: advance
        ) {
            VStack(spacing: 16) {
                ComparisonBar(
                    title: "Where you are now",
                    value: Double(currentScore) / 100.0,
                    accent: OVTheme.gold
                )

                ComparisonBar(
                    title: "With One Visioon",
                    value: 0.97,
                    accent: Color.white
                )

                FeatureCard(
                    title: "What changes",
                    lines: [
                        "You read Scripture with a clear next step.",
                        "You reflect on what God is showing you.",
                        "You build a steadier walk with God."
                    ]
                )

                Text("This is about getting back on track and growing for real.")
                    .font(OnboardingTypography.body(18, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("*This result is an indication only, not a medical diagnosis.")
                    .font(OnboardingTypography.caption)
                    .foregroundStyle(Color.white.opacity(0.6))
            }
        }
    }

    var goalsView: some View {
        QuestionLayout(
            title: "Set your goals",
            subtitle: "\(selectedGoalCategoryCount) of 4 categories selected",
            buttonTitle: "Build my path >",
            canContinue: selectedGoalCategoryCount == 4,
            action: advance
        ) {
            VStack(spacing: 14) {
                GoalProgressDiagram(selectedCount: selectedGoalCategoryCount, totalCount: 4)
                GoalCategoryCard(
                    category: goalCategories[0],
                    selection: $selectedMindsetGoal,
                    isExpanded: expandedGoalCategoryID == goalCategories[0].id,
                    onToggle: {
                        toggleGoalCategory(goalCategories[0].id)
                    },
                    onSelectionMade: {
                        handleGoalSelection(for: goalCategories[0].id)
                    }
                )
                GoalCategoryCard(
                    category: goalCategories[1],
                    selection: $selectedHealthGoal,
                    isExpanded: expandedGoalCategoryID == goalCategories[1].id,
                    onToggle: {
                        toggleGoalCategory(goalCategories[1].id)
                    },
                    onSelectionMade: {
                        handleGoalSelection(for: goalCategories[1].id)
                    }
                )
                GoalCategoryCard(
                    category: goalCategories[2],
                    selection: $selectedPurposeGoal,
                    isExpanded: expandedGoalCategoryID == goalCategories[2].id,
                    onToggle: {
                        toggleGoalCategory(goalCategories[2].id)
                    },
                    onSelectionMade: {
                        handleGoalSelection(for: goalCategories[2].id)
                    }
                )
                GoalCategoryCard(
                    category: goalCategories[3],
                    selection: $selectedCommunityGoal,
                    isExpanded: expandedGoalCategoryID == goalCategories[3].id,
                    onToggle: {
                        toggleGoalCategory(goalCategories[3].id)
                    },
                    onSelectionMade: {
                        handleGoalSelection(for: goalCategories[3].id)
                    }
                )
            }
        }
    }

    var futureIdentityView: some View {
        InfoScrollLayout(
            title: "What this path can build in you",
            subtitle: "With One Visioon, you grow one step at a time and build a stronger walk with God.",
            buttonTitle: "Continue",
            action: advance
        ) {
            VStack(spacing: 14) {
                FeatureCard(
                    title: "What you'll do here",
                    lines: [
                        "Read the Bible with a clear next step",
                        "Highlight verses that stand out",
                        "Write simple reflections after reading",
                        "Follow lessons that help you go deeper"
                    ]
                )

                FeatureCard(
                    title: "What that can lead to",
                    lines: [
                        "Feeling less lost when you open Scripture",
                        "Showing up with God more consistently",
                        "Thinking more clearly when life gets heavy",
                        "Living with more peace and direction"
                    ]
                )
            }
        }
    }

    var takeControlView: some View {
        let learnerName = fullName.trimmed.isEmpty ? "You" : fullName.trimmed

        return InfoScrollLayout(
            title: "The version of \(learnerName) this app can help build",
            subtitle: "Not perfect. Just more grounded, more steady, and more serious about growth with God.",
            buttonTitle: "Start my path",
            action: advance
        ) {
            VStack(spacing: 14) {
                FeatureCard(
                    title: "This version of you",
                    lines: [
                        "Opens the Bible even on off days",
                        "Knows what chapter to read next",
                        "Writes down what God is teaching",
                        "Lives with more peace, focus, and self-control"
                    ]
                )

                FeatureCard(
                    title: "What changes over time",
                    lines: [
                        "You stop starting over every week",
                        "You understand Scripture more deeply",
                        "Your habits start to stick",
                        "You grow with support instead of doing it alone"
                    ]
                )

                Text("That kind of growth starts with simple daily steps inside the app.")
                    .font(OnboardingTypography.body(17, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }

    var systemBlueprintView: some View {
        InfoScrollLayout(
            title: "One Visioon's mission is to help you become...",
            subtitle: "Simple steps. Real progress. One day at a time.",
            buttonTitle: "Continue",
            action: advance
        ) {
            VStack(spacing: 14) {
                MissionFlowCard(
                    steps: [
                        MissionFlowStep(
                            number: "01",
                            title: "Read",
                            detail: "Open the next chapter, lesson, or guide picked for you."
                        ),
                        MissionFlowStep(
                            number: "02",
                            title: "Reflect",
                            detail: "Highlight verses, save notes, and write what stood out."
                        ),
                        MissionFlowStep(
                            number: "03",
                            title: "Grow",
                            detail: "Build a steadier walk with God through simple daily steps."
                        )
                    ]
                )

                MissionOutcomeCard(
                    title: "What this can build in you",
                    items: [
                        MissionOutcomeItem(
                            icon: "book.closed.fill",
                            title: "Stronger Bible habit",
                            detail: "Know what to read next."
                        ),
                        MissionOutcomeItem(
                            icon: "sparkles",
                            title: "Clearer thinking",
                            detail: "Slow down and focus on truth."
                        ),
                        MissionOutcomeItem(
                            icon: "checkmark.seal.fill",
                            title: "More follow-through",
                            detail: "Keep going instead of restarting."
                        ),
                        MissionOutcomeItem(
                            icon: "heart.fill",
                            title: "Steadier walk with God",
                            detail: "Grow with more peace and direction."
                        )
                    ]
                )

                CommunityPreviewCard(
                    recommendedGroupTitle: recommendedChatGroupTitle
                )
            }
        }
    }

    var membershipView: some View {
        VStack(spacing: 0) {
            paywallHeader
                .padding(.horizontal, 22)
                .padding(.top, 24)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    Spacer()
                        .frame(height: 30)

                    VStack(spacing: 12) {
                        Text("Unlock full access")
                            .font(OnboardingTypography.hero(28))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text("Get full lessons, guided study, and a clearer path forward.")
                            .font(OnboardingTypography.body(16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.84))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)

                        Text("20% of profits go toward helping people in need.")
                            .font(OnboardingTypography.caption)
                            .foregroundStyle(Color.white.opacity(0.66))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 10) {
                if !paywallMessage.isEmpty {
                    MessageStripe(text: paywallMessage, tint: OVTheme.gold)
                } else if let error = accessManager.errorMessage, !error.isEmpty {
                    MessageStripe(text: error, tint: OVTheme.coral)
                }

                VStack(spacing: hasSelectedPremiumPlan ? 12 : 10) {
                    HStack(spacing: 12) {
                        PlanChoiceCard(
                            title: "Monthly",
                            price: monthlyPlanPrice,
                            cadence: monthlyPlanCadence,
                            selected: selectedPremiumPlan == "monthly",
                            badge: nil
                        ) {
                            selectPremiumPlan("monthly")
                        }

                        PlanChoiceCard(
                            title: "Yearly",
                            price: yearlyPlanPrice,
                            cadence: yearlyPlanCadence,
                            selected: selectedPremiumPlan == "yearly",
                            badge: yearlySavingsBadge
                        ) {
                            selectPremiumPlan("yearly")
                        }
                    }
                    .offset(y: hasSelectedPremiumPlan ? -6 : 0)
                    .animation(.spring(response: 0.34, dampingFraction: 0.86), value: hasSelectedPremiumPlan)

                    if hasSelectedPremiumPlan {
                        GlowButton(
                            title: accessManager.isPurchasing ? "Starting..." : "BEGIN",
                            action: startMembership
                        )
                        .disabled(accessManager.isPurchasing)
                        .opacity(accessManager.isPurchasing ? 0.6 : 1)
                        .transition(.move(edge: .bottom).combined(with: .opacity))

                        Text(selectedPlanSummaryLine)
                            .font(OnboardingTypography.body(13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.86))
                            .multilineTextAlignment(.center)

                        Text("Cancel anytime.")
                            .font(OnboardingTypography.caption)
                            .foregroundStyle(Color.white.opacity(0.68))
                            .multilineTextAlignment(.center)

                        Text("By continuing, you agree to our Terms of Use and Privacy Policy.")
                            .font(OnboardingTypography.caption)
                            .foregroundStyle(Color.white.opacity(0.62))
                            .multilineTextAlignment(.center)

                        if shouldShowStudyFallback {
                            Button {
                                continueWithBibleStudy()
                            } label: {
                                Text("Continue with Bible Study for now")
                                    .font(OnboardingTypography.body(14, weight: .bold))
                                    .foregroundStyle(Color.white.opacity(0.86))
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 2)
                        }
                    }
                }
                .animation(.spring(response: 0.34, dampingFraction: 0.86), value: hasSelectedPremiumPlan)
            }
            .padding(.horizontal, 22)
            .padding(.top, 14)
            .padding(.bottom, 22)
            .background(Color(hex: "0D1017").opacity(0.96))
        }
    }

    var paywallHeader: some View {
        HStack(alignment: .center) {
            Button("Restore") {
                restoreMembership()
            }
            .font(OnboardingTypography.body(14, weight: .bold))
            .foregroundStyle(Color.white.opacity(0.86))

            Spacer()

            HStack(spacing: 10) {
                LogoMark(size: 40, cornerRadius: 10)
                Text("One Visioon")
                    .font(OnboardingTypography.hero(22))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button {
                continueWithBibleStudy()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    func handleStepSideEffects() async {
        if step == .membership {
            guard accessManager.isMembershipEnabled else { return }
            await accessManager.refreshAccessState()
            await accessManager.loadProducts()
            return
        }

        if step == .goals {
            syncExpandedGoalCategory()
            return
        }

        guard step == .analysisLoading else { return }

        loadingMessageIndex = 0

        for index in 0..<loadingMessages.count {
            loadingMessageIndex = index
            try? await Task.sleep(nanoseconds: 900_000_000)
        }

        if step == .analysisLoading {
            go(to: .analysisComplete)
        }
    }

    func startMembership() {
        guard hasSelectedPremiumPlan else { return }
        paywallMessage = ""
        Task {
            let granted = await accessManager.purchaseSelectedPlan(selectedPremiumPlan)
            if granted || accessManager.isPreviewModeActive || accessManager.hasAccess {
                finishOnboarding()
            } else {
                paywallMessage = accessManager.errorMessage ?? "We couldn't unlock full access right now."
            }
        }
    }

    func restoreMembership() {
        paywallMessage = ""
        Task {
            if accessManager.isPreviewModeActive {
                finishOnboarding()
                return
            }

            await accessManager.restorePurchases()

            if accessManager.hasAccess {
                finishOnboarding()
            } else {
                paywallMessage = accessManager.errorMessage ?? "We couldn't find an active membership to restore."
            }
        }
    }

    func continueWithBibleStudy() {
        var profile = buildProfile()
        profile.selectedVersion = "study"
        profile.selectedPremiumPlan = ""
        store.completeOnboarding(profile: profile)
        paywallMessage = ""
    }

    func finishOnboarding() {
        var profile = buildProfile()
        profile.selectedVersion = "premium"
        profile.selectedPremiumPlan = selectedPremiumPlan
        store.completeOnboarding(profile: profile)
        updatePostPurchaseAccountRequirement(for: profile)
    }

    func buildProfile() -> OnboardingAnswerSet {
        let trimmedName = fullName.trimmed
        let cleanedUsername = username.trimmed.isEmpty ? defaultUsername(from: trimmedName) : username.trimmed
        let cadence = weeklyCommitment.isEmpty ? "Most days" : weeklyCommitment

        return OnboardingAnswerSet(
            fullName: trimmedName,
            username: cleanedUsername,
            email: email.trimmed,
            age: age.trimmed,
            country: country.trimmed,
            usaAreaCode: usaAreaCode.trimmed,
            gender: gender,
            faithStage: faithStage,
            biggestChallenge: biggestChallenge.isEmpty ? primaryStruggleSummary : biggestChallenge,
            scriptureRhythm: cadence,
            prayerRhythm: cadence,
            learningStyle: supportNeed,
            weeklyCommitment: cadence,
            reminderWindow: reminderWindow,
            selectedVersion: "premium",
            selectedPremiumPlan: selectedPremiumPlan.isEmpty ? "yearly" : selectedPremiumPlan,
            currentSeason: currentSeason.isEmpty ? faithStage : currentSeason,
            currentStruggles: Array(currentStruggles).sorted(),
            lifeVision: lifeVision,
            desiredGrowth: desiredGrowth,
            behindArea: behindArea,
            ifNothingChangesFeeling: ifNothingChangesFeeling,
            futureStrength: futureStrength,
            supportNeed: supportNeed,
            spiritualStruggle: spiritualStruggle,
            readinessResponse: readinessResponse,
            wantsNotifications: wantsNotifications,
            referralCode: referralCode.trimmed,
            heardAboutSource: heardAboutSource,
            selectedMindsetGoal: selectedMindsetGoal,
            selectedHealthGoal: selectedHealthGoal,
            selectedPurposeGoal: selectedPurposeGoal,
            selectedCommunityGoal: selectedCommunityGoal,
            onboardingPotentialScore: potentialScore
        )
    }

    func completeReturningSignIn() {
        let existingProfile = store.onboardingProfile
        let resolvedPlan = existingProfile.selectedPremiumPlan.isEmpty ? "yearly" : existingProfile.selectedPremiumPlan
        let profile = OnboardingAnswerSet(
            fullName: existingProfile.fullName.trimmed.isEmpty
                ? authManager.currentSession?.displayName.trimmed ?? ""
                : existingProfile.fullName.trimmed,
            username: existingProfile.username,
            email: existingProfile.email.trimmed.isEmpty
                ? authManager.currentSession?.email.trimmed ?? ""
                : existingProfile.email.trimmed,
            age: existingProfile.age,
            country: existingProfile.country,
            usaAreaCode: existingProfile.usaAreaCode,
            gender: existingProfile.gender,
            faithStage: existingProfile.faithStage,
            biggestChallenge: existingProfile.biggestChallenge,
            scriptureRhythm: existingProfile.scriptureRhythm,
            prayerRhythm: existingProfile.prayerRhythm,
            learningStyle: existingProfile.learningStyle,
            weeklyCommitment: existingProfile.weeklyCommitment,
            reminderWindow: existingProfile.reminderWindow,
            selectedVersion: existingProfile.selectedVersion.isEmpty ? "premium" : existingProfile.selectedVersion,
            selectedPremiumPlan: resolvedPlan,
            currentSeason: existingProfile.currentSeason,
            currentStruggles: existingProfile.currentStruggles,
            lifeVision: existingProfile.lifeVision,
            desiredGrowth: existingProfile.desiredGrowth,
            behindArea: existingProfile.behindArea,
            ifNothingChangesFeeling: existingProfile.ifNothingChangesFeeling,
            futureStrength: existingProfile.futureStrength,
            supportNeed: existingProfile.supportNeed,
            spiritualStruggle: existingProfile.spiritualStruggle,
            readinessResponse: existingProfile.readinessResponse,
            wantsNotifications: existingProfile.wantsNotifications,
            referralCode: existingProfile.referralCode,
            heardAboutSource: existingProfile.heardAboutSource,
            selectedMindsetGoal: existingProfile.selectedMindsetGoal,
            selectedHealthGoal: existingProfile.selectedHealthGoal,
            selectedPurposeGoal: existingProfile.selectedPurposeGoal,
            selectedCommunityGoal: existingProfile.selectedCommunityGoal,
            onboardingPotentialScore: existingProfile.onboardingPotentialScore
        )
        store.completeOnboarding(profile: profile)
        updatePostPurchaseAccountRequirement(for: profile)
    }

    func updatePostPurchaseAccountRequirement(for profile: OnboardingAnswerSet) {
        guard profile.selectedVersion == "premium" else { return }

        if authManager.isSignedIn {
            store.completePostPurchaseAccountLink()
        } else {
            store.requirePostPurchaseAccountLink()
        }
    }

    func hydrateFromProfile(_ profile: OnboardingAnswerSet) {
        fullName = profile.fullName
        username = profile.username
        email = profile.email
        age = profile.age
        country = profile.country
        usaAreaCode = profile.usaAreaCode
        gender = profile.gender
        faithStage = profile.faithStage
        currentSeason = profile.currentSeason
        currentStruggles = Set(profile.currentStruggles)
        biggestChallenge = profile.biggestChallenge
        lifeVision = profile.lifeVision
        desiredGrowth = profile.desiredGrowth
        behindArea = profile.behindArea
        ifNothingChangesFeeling = profile.ifNothingChangesFeeling
        futureStrength = profile.futureStrength
        weeklyCommitment = profile.weeklyCommitment
        scriptureRhythm = profile.scriptureRhythm
        prayerRhythm = profile.prayerRhythm
        learningStyle = profile.learningStyle
        supportNeed = profile.supportNeed
        spiritualStruggle = profile.spiritualStruggle
        readinessResponse = profile.readinessResponse
        reminderWindow = profile.reminderWindow
        wantsNotifications = profile.wantsNotifications
        referralCode = profile.referralCode
        heardAboutSource = profile.heardAboutSource
        selectedMindsetGoal = profile.selectedMindsetGoal
        selectedHealthGoal = profile.selectedHealthGoal
        selectedPurposeGoal = profile.selectedPurposeGoal
        selectedCommunityGoal = profile.selectedCommunityGoal
        selectedPremiumPlan = profile.selectedPremiumPlan
        syncLocationPickers()
    }

    func advance() {
        go(to: nextStep(after: step))
    }

    func selectPremiumPlan(_ plan: String) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
            selectedPremiumPlan = plan
        }
    }

    func toggleGoalCategory(_ id: String) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            expandedGoalCategoryID = expandedGoalCategoryID == id ? nil : id
        }
    }

    func handleGoalSelection(for id: String) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            expandedGoalCategoryID = nextUnselectedGoalCategoryID(after: id)
        }
    }

    func syncLocationPickers() {
        if !usesUnitedStatesCountry {
            usaAreaCode = ""
            isAreaCodePickerExpanded = false
        }
    }

    func syncExpandedGoalCategory() {
        if selectedGoalCategoryCount == goalCategories.count {
            expandedGoalCategoryID = nil
            return
        }

        expandedGoalCategoryID = nextUnselectedGoalCategoryID(after: nil)
    }

    func nextUnselectedGoalCategoryID(after currentID: String?) -> String? {
        let orderedIDs = goalCategories.map(\.id)

        let remainingIDs: [String]
        if let currentID, let currentIndex = orderedIDs.firstIndex(of: currentID) {
            remainingIDs = Array(orderedIDs.dropFirst(currentIndex + 1))
        } else {
            remainingIDs = orderedIDs
        }

        if let next = remainingIDs.first(where: { goalSelection(for: $0).isEmpty }) {
            return next
        }

        if currentID != nil {
            return orderedIDs.first(where: { goalSelection(for: $0).isEmpty })
        }

        return nil
    }

    func goalSelection(for id: String) -> String {
        switch id {
        case "mindset":
            return selectedMindsetGoal
        case "health":
            return selectedHealthGoal
        case "purpose":
            return selectedPurposeGoal
        case "community":
            return selectedCommunityGoal
        default:
            return ""
        }
    }

    func advanceAfterSelection(from source: OnboardingStage) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 140_000_000)
            guard step == source else { return }
            advance()
        }
    }

    func go(to newStep: OnboardingStage) {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
            if newStep == .membership && !store.onboardingCompleted {
                selectedPremiumPlan = ""
            }
            step = newStep
        }
    }

    func nextStep(after stage: OnboardingStage) -> OnboardingStage {
        switch stage {
        case .welcome: return .quizIntro
        case .quizIntro: return .greekCorrelation
        case .greekCorrelation: return .gender
        case .gender: return .lifeState
        case .lifeState: return .latelyIssues
        case .latelyIssues: return .lifeVision
        case .quizComplete: return .lifeVision
        case .lifeVision: return .desiredGrowth
        case .desiredGrowth: return .behindArea
        case .behindArea: return .oneYearFeeling
        case .oneYearFeeling: return .futureStrength
        case .futureStrength: return .cadence
        case .greatWork: return .cadence
        case .cadence: return .supportNeed
        case .supportNeed: return .spiritualStruggle
        case .spiritualStruggle: return .readiness
        case .readiness: return .notifications
        case .notifications: return .referral
        case .books: return .principles
        case .principles: return .referral
        case .referral: return .personalBasics
        case .reviews: return .personalBasics
        case .personalBasics: return .discovery
        case .discovery: return .analysisLoading
        case .analysisLoading: return .analysisComplete
        case .analysisComplete: return .withOneVisioon
        case .withOneVisioon: return .goals
        case .goals: return .futureIdentity
        case .futureIdentity: return .takeControl
        case .takeControl: return .systemBlueprint
        case .systemBlueprint: return .membership
        case .membership: return .membership
        }
    }

    func requestNotifications() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func mirrorLegacyValuesIfNeeded(for selection: String) {
        switch step {
        case .lifeState:
            currentSeason = selection
        case .cadence:
            scriptureRhythm = selection
            prayerRhythm = selection
            weeklyCommitment = selection
        case .supportNeed:
            learningStyle = selection
        default:
            break
        }
    }

    func defaultUsername(from name: String) -> String {
        let lowered = name.lowercased()
        let slug = lowered
            .split(separator: " ")
            .joined(separator: ".")
            .filter { $0.isLetter || $0.isNumber || $0 == "." || $0 == "_" }
        return slug.isEmpty ? "" : slug
    }

    func backgroundAssetName(for stage: OnboardingStage) -> String? {
        switch stage {
        case .welcome:
            return "bg1"
        case .quizIntro:
            return "bg2"
        case .greekCorrelation:
            return "bg2"
        case .quizComplete:
            return "bg3"
        case .greatWork:
            return "bg4"
        case .principles:
            return "bg5"
        default:
            return nil
        }
    }

    var primaryStruggleSummary: String {
        if let strongest = currentStruggles.first(where: { $0.localizedCaseInsensitiveContains("direction") }) {
            return strongest
        }
        return currentStruggles.sorted().first ?? spiritualStruggle
    }

    var potentialScore: Int {
        var score = 72

        switch faithStage {
        case "I feel far from God":
            score -= 22
        case "I'm trying, but I'm not consistent":
            score -= 15
        case "I'm growing, but I need structure":
            score -= 8
        case "I'm doing well, but I want more":
            score -= 4
        default:
            break
        }

        score -= min(currentStruggles.count * 4, 16)

        switch weeklyCommitment {
        case "Only when I really need it":
            score -= 12
        case "A few times a week":
            score -= 7
        case "Most days":
            score -= 3
        case "Every day":
            score += 2
        default:
            break
        }

        switch ifNothingChangesFeeling {
        case "That scares me":
            score -= 12
        case "Regretful":
            score -= 10
        case "Disappointed":
            score -= 8
        case "Stressed":
            score -= 7
        case "Still stuck":
            score -= 5
        default:
            break
        }

        if !spiritualStruggle.isEmpty {
            score -= 6
        }

        return min(84, max(28, score))
    }

    var selectedGoalCategoryCount: Int {
        [selectedMindsetGoal, selectedHealthGoal, selectedPurposeGoal, selectedCommunityGoal]
            .filter { !$0.isEmpty }
            .count
    }

    var hasSelectedPremiumPlan: Bool {
        !selectedPremiumPlan.isEmpty
    }

    var shouldShowStudyFallback: Bool {
        let combined = "\(paywallMessage) \(accessManager.errorMessage ?? "")".lowercased()
        return combined.contains("plans are unavailable")
            || combined.contains("unavailable right now")
    }

    var recommendedChatGroupTitle: String {
        switch spiritualStruggle {
        case "Lust or impurity":
            return "Purity Circle"
        case "Worry or anxiety":
            return "Peace & Trust Circle"
        case "Anger":
            return "Slow to Anger Circle"
        case "Pride":
            return "Humility Circle"
        case "Gossip or careless words":
            return "Integrity in Speech Circle"
        case "Lying":
            return "Truth & Integrity Circle"
        case "Hypocrisy":
            return "Honest Walk Circle"
        default:
            return "Focused Growth Group"
        }
    }

    var selectedPlanSummaryLine: String {
        guard hasSelectedPremiumPlan else { return "" }

        if selectedPremiumPlan == "yearly" {
            guard accessManager.yearlyProduct != nil else {
                return "Apple will show the exact price before purchase."
            }

            if yearlySavingsPercent > 0 {
                return "\(yearlyPlanPrice)/yr billed yearly. Saves \(yearlySavingsPercent)% versus monthly."
            }

            return "\(yearlyPlanPrice)/yr billed yearly."
        }

        guard accessManager.monthlyProduct != nil else {
            return "Apple will show the exact price before purchase."
        }

        return "\(monthlyPlanPrice)/mo. Apple confirms before purchase."
    }

    var monthlyPlanPrice: String {
        accessManager.monthlyProduct?.displayPrice ?? "..."
    }

    var monthlyPlanCadence: String {
        accessManager.monthlyProduct == nil ? "" : "/mo"
    }

    var yearlyPlanPrice: String {
        accessManager.yearlyProduct?.displayPrice ?? "..."
    }

    var yearlyPlanCadence: String {
        accessManager.yearlyProduct == nil ? "" : "/yr"
    }

    var yearlySavingsBadge: String? {
        yearlySavingsPercent > 0 ? "\(yearlySavingsPercent)% OFF" : nil
    }

    var yearlySavingsPercent: Int {
        guard let monthlyProduct = accessManager.monthlyProduct,
              let yearlyProduct = accessManager.yearlyProduct else {
            return 0
        }

        let monthlyYearCost = NSDecimalNumber(decimal: monthlyProduct.price).doubleValue * 12
        let yearlyCost = NSDecimalNumber(decimal: yearlyProduct.price).doubleValue
        guard monthlyYearCost > 0, yearlyCost > 0, yearlyCost < monthlyYearCost else {
            return 0
        }

        let savings = (1.0 - (yearlyCost / monthlyYearCost)) * 100.0
        return Int(round(savings))
    }

    var usesUnitedStatesCountry: Bool {
        let normalized = country.trimmed.lowercased()
        return normalized == "united states" || normalized == "united states of america" || normalized == "usa" || normalized == "us"
    }

    var countryOptions: [String] {
        CountryDirectory.names
    }

    var areaCodeOptions: [String] {
        USAreaCodeDirectory.codes
    }

    var genderOptions: [Option] {
        [
            Option("Male"),
            Option("Female"),
            Option("Non-binary"),
            Option("Prefer not to say")
        ]
    }

    var faithStageOptions: [Option] {
        [
            Option("I feel far from God", detail: "I need a fresh start."),
            Option("I'm trying, but I'm not consistent", detail: "I care, but I keep falling off."),
            Option("I'm growing, but I need structure", detail: "I want growth that lasts."),
            Option("I'm doing well, but I want more", detail: "I want to go deeper with God.")
        ]
    }

    var currentStruggleOptions: [Option] {
        [
            Option("I feel low on motivation"),
            Option("I overthink everything"),
            Option("I have been sleeping badly"),
            Option("I feel alone"),
            Option("My confidence is low"),
            Option("I keep procrastinating"),
            Option("I feel lost about direction")
        ]
    }

    var lifeVisionOptions: [Option] {
        [
            Option("I want more self-control"),
            Option("I want more peace"),
            Option("I want more courage and purpose"),
            Option("I want to live more like Christ")
        ]
    }

    var desiredGrowthOptions: [Option] {
        [
            Option("Clear direction"),
            Option("More discipline"),
            Option("More confidence in Christ"),
            Option("Fresh motivation"),
            Option("More peace")
        ]
    }

    var behindAreaOptions: [Option] {
        [
            Option("Daily habits"),
            Option("Mental and emotional peace"),
            Option("Health and energy"),
            Option("Work or school"),
            Option("Relationships")
        ]
    }

    var oneYearFeelingOptions: [Option] {
        [
            Option("Disappointed"),
            Option("Regretful"),
            Option("Stressed"),
            Option("Still stuck"),
            Option("That scares me")
        ]
    }

    var futureStrengthOptions: [Option] {
        [
            Option("Keep a healthy routine"),
            Option("Take action faster"),
            Option("Stay calm with my emotions"),
            Option("Know what matters most"),
            Option("Finish what I start")
        ]
    }

    var cadenceOptions: [Option] {
        [
            Option("Every day"),
            Option("Most days"),
            Option("A few times a week"),
            Option("Only when I really need it")
        ]
    }

    var supportNeedOptions: [Option] {
        [
            Option("A simple plan"),
            Option("Daily Bible guidance"),
            Option("Real accountability"),
            Option("Encouragement when I slip"),
            Option("Proof that I'm making progress")
        ]
    }

    var spiritualStruggleOptions: [Option] {
        [
            Option("Lust or impurity"),
            Option("Pride"),
            Option("Greed"),
            Option("Envy"),
            Option("Anger"),
            Option("Laziness"),
            Option("Overeating or lack of control"),
            Option("Gossip or careless words"),
            Option("Lying"),
            Option("Worry or anxiety"),
            Option("Hypocrisy")
        ]
    }

    var readinessOptions: [Option] {
        [
            Option("I'm ready to start"),
            Option("I need clear guidance"),
            Option("I need structure"),
            Option("I don't want to waste more time")
        ]
    }

    var discoveryOptions: [Option] {
        [
            Option("Google"),
            Option("Instagram"),
            Option("TikTok"),
            Option("X"),
            Option("Other")
        ]
    }

    var goalCategories: [GoalCategory] {
        [
            GoalCategory(
                id: "mindset",
                title: "Mindset",
                options: [
                    "Calm my thoughts",
                    "Build confidence in Christ",
                    "Stop negative self-talk",
                    "Grow self-control"
                ]
            ),
            GoalCategory(
                id: "health",
                title: "Health",
                options: [
                    "Sleep better",
                    "Have more energy",
                    "Build a healthy routine",
                    "Take better care of my body"
                ]
            ),
            GoalCategory(
                id: "purpose",
                title: "Purpose",
                options: [
                    "Get clear on my calling",
                    "Be more consistent at work or school",
                    "Handle money wisely",
                    "Lead with integrity"
                ]
            ),
            GoalCategory(
                id: "community",
                title: "Community",
                options: [
                    "Build better friendships",
                    "Heal a relationship",
                    "Find honest Christian community",
                    "Encourage people better"
                ]
            )
        ]
    }

    var inspirationBooks: [BookHighlight] {
        [
            BookHighlight(
                id: "presence",
                title: "The Practice of the Presence of God",
                author: "Brother Lawrence",
                quote: "There is not in the world a kind of life more sweet and delightful than that of a continual conversation with God.",
                citation: "Lawrence, Brother. (1692/Project Gutenberg ed.) The Practice of the Presence of God.",
                accent: OVTheme.gold
            ),
            BookHighlight(
                id: "imitation",
                title: "The Imitation of Christ",
                author: "Thomas à Kempis",
                quote: "Without the way thou canst not go, without the truth thou canst not know, without the life thou canst not live.",
                citation: "Thomas à Kempis. (1418–1427/Project Gutenberg ed.) The Imitation of Christ.",
                accent: Color(hex: "9A7B45")
            ),
            BookHighlight(
                id: "steps",
                title: "In His Steps",
                author: "Charles M. Sheldon",
                quote: "What would Jesus do?",
                citation: "Sheldon, C. M. (1896/Project Gutenberg ed.) In His Steps.",
                accent: Color(hex: "6D5A37")
            )
        ]
    }

    var testimonials: [Testimonial] {
        [
            Testimonial(
                id: "t1",
                name: "Noah R.",
                subtitle: "5 stars",
                quote: "This feels calm and useful. It gets me back into Scripture instead of just hyping me up for five minutes.",
                assetName: "pfp1"
            ),
            Testimonial(
                id: "t2",
                name: "Maya T.",
                subtitle: "5 stars",
                quote: "I liked that it asked real questions first. It feels like the app wants to understand me, not just sell to me.",
                assetName: "pfp2"
            ),
            Testimonial(
                id: "t3",
                name: "Eli W.",
                subtitle: "5 stars",
                quote: "The chapter-by-chapter lessons got me. It feels more like real guidance than another Christian content feed.",
                assetName: "pfp3"
            )
        ]
    }
}

private struct QuestionLayout<Content: View>: View {
    let title: String
    let subtitle: String
    let buttonTitle: String?
    let secondaryButtonTitle: String?
    let canContinue: Bool
    let action: (() -> Void)?
    let secondaryAction: (() -> Void)?
    @ViewBuilder let content: Content

    init(
        title: String,
        subtitle: String,
        buttonTitle: String? = nil,
        secondaryButtonTitle: String? = nil,
        canContinue: Bool,
        action: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.canContinue = canContinue
        self.action = action
        self.secondaryAction = secondaryAction
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer()
                        .frame(height: 76)

                    Text(title)
                        .font(OnboardingTypography.hero(30))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subtitle)
                        .font(OnboardingTypography.body(14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    content
                }
                .padding(.horizontal, 22)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)

            VStack(spacing: 10) {
                if let secondaryButtonTitle, let secondaryAction {
                    SecondaryOutlineButton(
                        title: secondaryButtonTitle,
                        action: secondaryAction
                    )
                }

                if let buttonTitle, let action {
                    GlowButton(
                        title: buttonTitle,
                        action: action
                    )
                    .disabled(!canContinue)
                    .opacity(canContinue ? 1 : 0.45)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, buttonTitle == nil && secondaryButtonTitle == nil ? 0 : 10)
            .padding(.bottom, buttonTitle == nil && secondaryButtonTitle == nil ? 14 : 22)
            .background(Color.black.opacity(0.001))
        }
    }
}

private struct InfoScrollLayout<Content: View>: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void
    @ViewBuilder let content: Content

    init(
        title: String,
        subtitle: String,
        buttonTitle: String,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.action = action
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer()
                        .frame(height: 78)

                    Text(title)
                        .font(OnboardingTypography.hero(32))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subtitle)
                        .font(OnboardingTypography.body(15, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    content
                }
                .padding(.horizontal, 22)
                .frame(maxWidth: .infinity)
                .padding(.top, 42)
                .padding(.bottom, 24)
            }

            GlowButton(title: buttonTitle, action: action)
                .padding(.horizontal, 22)
                .padding(.bottom, 22)
        }
    }
}

private struct ScenicIntroLayout: View {
    let title: String
    let subtitle: String
    let detail: String?
    let buttonTitle: String
    let assetName: String
    let action: () -> Void

    var body: some View {
        ZStack {
            OnboardingSceneBackground(assetName: assetName, fallbackSeed: 77)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 128)

                VStack(spacing: 14) {
                    Text(title)
                        .font(OnboardingTypography.hero(34))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(OnboardingTypography.body(16, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .multilineTextAlignment(.center)

                    if let detail {
                        Text(detail)
                            .font(OnboardingTypography.body(15, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.82))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.top, 6)
                    }
                }
                .padding(.horizontal, 28)

                Spacer()

                GlowButton(title: buttonTitle, action: action)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 34)
            }
        }
    }
}

private struct SelectionCard: View {
    let title: String
    let detail: String?
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: detail == nil ? 0 : 6) {
                Text(title)
                    .font(OnboardingTypography.body(16, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                if let detail, !detail.isEmpty {
                    Text(detail)
                        .font(OnboardingTypography.body(13, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(selected ? OnboardingColors.selectedCard : OnboardingColors.card)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(selected ? OnboardingColors.goldBorder : OnboardingColors.border, lineWidth: selected ? 1.6 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct GlowButton: View {
    enum WidthStyle {
        case fill
        case fit
    }

    let title: String
    var style: WidthStyle = .fill
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(OnboardingTypography.body(16, weight: .bold))
                .foregroundStyle(OVTheme.midnight)
                .padding(.horizontal, style == .fit ? 36 : 18)
                .frame(maxWidth: style == .fill ? .infinity : nil)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.88), lineWidth: 1)
                )
                .shadow(color: Color.white.opacity(0.12), radius: 12, y: 0)
                .shadow(color: OVTheme.gold.opacity(0.12), radius: 18, y: 0)
        }
        .buttonStyle(.plain)
    }
}

private struct SecondaryOutlineButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(OnboardingTypography.body(15, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(OnboardingColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(OnboardingColors.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct FeatureCard: View {
    let title: String
    let lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(OnboardingTypography.body(16, weight: .bold))
                .foregroundStyle(.white)

            ForEach(lines, id: \.self) { line in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(OVTheme.gold)
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)
                    Text(line)
                        .font(OnboardingTypography.body(14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(18)
        .background(OnboardingColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(OnboardingColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct MissionFlowStep: Identifiable {
    let id = UUID()
    let number: String
    let title: String
    let detail: String
}

private struct MissionOutcomeItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}

private struct RatingSignalCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Early users are loving the experience")
                .font(OnboardingTypography.body(16, weight: .bold))
                .foregroundStyle(.white)

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(OVTheme.gold)
                        }
                    }

                    Text("Calm, clear, and built for real growth.")
                        .font(OnboardingTypography.body(14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(OVTheme.gold.opacity(0.18))
                        .frame(width: 84, height: 84)

                    Circle()
                        .stroke(OVTheme.gold.opacity(0.9), lineWidth: 1.4)
                        .frame(width: 84, height: 84)

                    VStack(spacing: 2) {
                        Text("4.9")
                            .font(OnboardingTypography.hero(28))
                            .foregroundStyle(.white)
                        Text("rating")
                            .font(OnboardingTypography.caption)
                            .foregroundStyle(Color.white.opacity(0.7))
                    }
                }
            }

            HStack(spacing: -8) {
                ForEach(["N", "M", "E"], id: \.self) { initial in
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 34, height: 34)
                        .overlay {
                            Text(initial)
                                .font(OnboardingTypography.body(14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .overlay(
                            Circle()
                                .stroke(OnboardingColors.border, lineWidth: 1)
                        )
                }

                Text("From our early users")
                    .font(OnboardingTypography.body(13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .padding(.leading, 14)
            }
        }
        .padding(18)
        .background(OnboardingColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(OnboardingColors.goldBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct MissionFlowCard: View {
    let steps: [MissionFlowStep]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How it works")
                .font(OnboardingTypography.body(16, weight: .bold))
                .foregroundStyle(.white)

            ForEach(steps) { step in
                HStack(alignment: .top, spacing: 14) {
                    Text(step.number)
                        .font(OnboardingTypography.body(12, weight: .bold))
                        .foregroundStyle(OVTheme.midnight)
                        .frame(width: 36, height: 36)
                        .background(OVTheme.gold)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(OnboardingTypography.body(15, weight: .bold))
                            .foregroundStyle(.white)

                        Text(step.detail)
                            .font(OnboardingTypography.body(13, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.78))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                }
                .padding(14)
                .background(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(OnboardingColors.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(18)
        .background(OnboardingColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(OnboardingColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct MissionOutcomeCard: View {
    let title: String
    let items: [MissionOutcomeItem]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(OnboardingTypography.body(16, weight: .bold))
                .foregroundStyle(.white)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: item.icon)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(OVTheme.gold)

                        Text(item.title)
                            .font(OnboardingTypography.body(14, weight: .bold))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(item.detail)
                            .font(OnboardingTypography.body(12, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.72))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
                    .padding(14)
                    .background(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(OnboardingColors.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
        .padding(18)
        .background(OnboardingColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(OnboardingColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct CommunityPreviewCard: View {
    let recommendedGroupTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Community spaces")
                .font(OnboardingTypography.body(16, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                communityBox(
                    title: "General Chat",
                    detail: "Coming after launch as the community grows."
                )

                communityBox(
                    title: recommendedGroupTitle,
                    detail: "Placeholder while we collect feedback."
                )
            }
        }
        .padding(18)
        .background(OnboardingColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(OnboardingColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    @ViewBuilder
    private func communityBox(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(OnboardingTypography.body(14, weight: .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(detail)
                .font(OnboardingTypography.body(12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
        .padding(14)
        .background(Color.white.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(OnboardingColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct BookHighlightCard: View {
    let book: OnboardingView.BookHighlight

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            SmallBookCover(title: book.title, accent: book.accent)

            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(OnboardingTypography.body(16, weight: .bold))
                    .foregroundStyle(.white)

                Text("“\(book.quote)”")
                    .font(OnboardingTypography.body(14, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)

                Text(book.citation)
                    .font(OnboardingTypography.caption)
                    .foregroundStyle(Color.white.opacity(0.56))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .background(OnboardingColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(OnboardingColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct SmallBookCover: View {
    let title: String
    let accent: Color

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accent.opacity(0.95), OVTheme.midnight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(title)
                .font(OnboardingTypography.body(13, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .padding(12)
        }
        .frame(width: 92, height: 128)
    }
}

private struct StarRow: View {
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(OVTheme.gold)
            }
        }
    }
}

private struct TestimonialCard: View {
    let testimonial: OnboardingView.Testimonial

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if UIImage(named: testimonial.assetName) != nil {
                Image(testimonial.assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(OVTheme.gold.opacity(0.24))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text(String(testimonial.name.prefix(1)))
                            .font(OnboardingTypography.body(18, weight: .bold))
                            .foregroundStyle(.white)
                    }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(testimonial.name)
                        .font(OnboardingTypography.body(15, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    StarRow()
                }

                Text(testimonial.quote)
                    .font(OnboardingTypography.body(14, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(OnboardingColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(OnboardingColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct OnboardingInputField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(OnboardingTypography.body(14, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))

            TextField(
                "",
                text: $text,
                prompt: Text(title)
                    .foregroundStyle(
                        Color.white.opacity(isFocused ? 0.52 : 0.38)
                    )
            )
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(true)
                .submitLabel(.next)
                .font(OnboardingTypography.body(18, weight: .semibold))
                .foregroundStyle(.white)
                .focused($isFocused)
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
                .background(isFocused ? OnboardingColors.selectedCard : OnboardingColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            isFocused ? OnboardingColors.goldBorder : OnboardingColors.border,
                            lineWidth: isFocused ? 1.4 : 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .animation(.easeInOut(duration: 0.16), value: isFocused)
        }
    }
}

private struct OnboardingPickerField: View {
    let title: String
    @Binding var selection: String
    @Binding var isExpanded: Bool
    let options: [String]
    let placeholder: String

    @State private var searchText = ""

    private var filteredOptions: [String] {
        let cleaned = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleaned.isEmpty else { return options }
        return options.filter { $0.lowercased().contains(cleaned) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(OnboardingTypography.body(14, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? placeholder : selection)
                        .font(OnboardingTypography.body(18, weight: .semibold))
                        .foregroundStyle(selection.isEmpty ? Color.white.opacity(0.42) : .white)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
                .background(OnboardingColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            selection.isEmpty ? OnboardingColors.border : OnboardingColors.goldBorder,
                            lineWidth: 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 12) {
                    TextField(
                        "Search",
                        text: $searchText,
                        prompt: Text("Search")
                            .foregroundStyle(Color.white.opacity(0.38))
                    )
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(true)
                    .font(OnboardingTypography.body(16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(OnboardingColors.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(OnboardingColors.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(filteredOptions, id: \.self) { option in
                                Button {
                                    selection = option
                                    searchText = ""
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                                        isExpanded = false
                                    }
                                } label: {
                                    HStack {
                                        Text(option)
                                            .font(OnboardingTypography.body(16, weight: .semibold))
                                            .foregroundStyle(.white)

                                        Spacer()

                                        if selection == option {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundStyle(OVTheme.gold)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(selection == option ? OnboardingColors.selectedCard : OnboardingColors.card)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(selection == option ? OnboardingColors.goldBorder : OnboardingColors.border, lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 240)
                }
            }
        }
    }
}

private struct ComparisonBar: View {
    let title: String
    let value: Double
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(OnboardingTypography.body(14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(OnboardingTypography.body(13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.76))
            }

            Capsule()
                .fill(Color.white.opacity(0.1))
                .frame(height: 12)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .mask(alignment: .leading) {
                            GeometryReader { proxy in
                                Rectangle()
                                    .frame(width: proxy.size.width * value)
                            }
                        }
                }
        }
        .padding(18)
        .background(OnboardingColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(OnboardingColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct QuotePanel: View {
    let quote: String
    let attribution: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("“\(quote)”")
                .font(OnboardingTypography.body(16, weight: .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(attribution)
                .font(OnboardingTypography.caption)
                .foregroundStyle(Color.white.opacity(0.64))
        }
        .padding(18)
        .background(OnboardingColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(OnboardingColors.goldBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct GoalCategoryCard: View {
    let category: OnboardingView.GoalCategory
    @Binding var selection: String
    let isExpanded: Bool
    let onToggle: () -> Void
    let onSelectionMade: () -> Void

    var body: some View {
        let isSelected = !selection.isEmpty

        return VStack(spacing: 12) {
            Button(action: onToggle) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category.title)
                            .font(OnboardingTypography.body(17, weight: .bold))
                            .foregroundStyle(.white)

                        Text(isSelected ? selection : "Pick one")
                            .font(OnboardingTypography.body(13, weight: .semibold))
                            .foregroundStyle(isSelected ? Color.white.opacity(0.82) : Color.white.opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isSelected ? OVTheme.gold : Color.white.opacity(0.78))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Circle())
                }
                .padding(18)
                .background(isSelected ? OnboardingColors.selectedCard : OnboardingColors.card.opacity(0.65))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(isSelected ? OnboardingColors.goldBorder : OnboardingColors.border, lineWidth: isSelected ? 1.5 : 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 10) {
                    ForEach(category.options, id: \.self) { option in
                        GoalOptionRow(
                            title: option,
                            selected: selection == option
                        ) {
                            selection = option
                            onSelectionMade()
                        }
                    }
                }
                .padding(.horizontal, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

private struct GoalOptionRow: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Circle()
                    .strokeBorder(selected ? OnboardingColors.goldBorder : Color.white.opacity(0.38), lineWidth: 1.4)
                    .background(
                        Circle()
                            .fill(selected ? OVTheme.gold : Color.clear)
                    )
                    .frame(width: 20, height: 20)

                Text(title)
                    .font(OnboardingTypography.body(14, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(selected ? OnboardingColors.selectedCard.opacity(0.92) : OnboardingColors.card.opacity(0.55))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? OnboardingColors.goldBorder : OnboardingColors.border, lineWidth: selected ? 1.4 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct GoalToggleRow: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(selected ? OVTheme.gold : Color.white.opacity(0.08))
                    .frame(width: 42, height: 26)
                    .overlay(alignment: selected ? .trailing : .leading) {
                        Circle()
                            .fill(.white)
                            .frame(width: 18, height: 18)
                            .padding(4)
                    }

                Text(title)
                    .font(OnboardingTypography.body(14, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(selected ? OnboardingColors.selectedCard : OnboardingColors.card)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? OnboardingColors.goldBorder : OnboardingColors.border, lineWidth: selected ? 1.4 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct GoalProgressDiagram: View {
    let selectedCount: Int
    let totalCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your goals")
                .font(OnboardingTypography.body(15, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                ForEach(0..<totalCount, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(index < selectedCount ? OVTheme.gold : Color.white.opacity(0.08))
                        .frame(height: 12)
                }
            }
        }
        .padding(16)
        .background(OnboardingColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(OnboardingColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct PlanChoiceCard: View {
    let title: String
    let price: String
    let cadence: String
    let selected: Bool
    let badge: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Text(title)
                        .font(OnboardingTypography.body(16, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()

                    if let badge {
                        Text(badge)
                            .font(OnboardingTypography.body(10, weight: .bold))
                            .foregroundStyle(OVTheme.midnight)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(OVTheme.gold)
                            .clipShape(Capsule())
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(price)
                        .font(OnboardingTypography.hero(30))
                        .foregroundStyle(selected ? OVTheme.gold : .white)
                    Text(cadence)
                        .font(OnboardingTypography.body(13, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
            .padding(16)
            .background(selected ? OnboardingColors.selectedCard : OnboardingColors.card)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(selected ? OnboardingColors.goldBorder : OnboardingColors.border, lineWidth: selected ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct MessageStripe: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(OnboardingTypography.body(13, weight: .semibold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(tint.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct OnboardingSceneBackground: View {
    let assetName: String?
    let fallbackSeed: Int

    var body: some View {
        ZStack {
            Color(hex: "0D1017")

            if let assetName, UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(0.28)
            }

            Circle()
                .fill(seedColor.opacity(0.09))
                .frame(width: 300, height: 300)
                .blur(radius: 62)
                .offset(x: -120, y: -280)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 260, height: 260)
                .blur(radius: 76)
                .offset(x: 135, y: 290)

            Color.black.opacity(assetName == nil ? 0.2 : 0.34)
        }
        .ignoresSafeArea()
    }

    private var seedColor: Color {
        let palette = [
            OVTheme.gold,
            Color(hex: "9B7A3E"),
            Color(hex: "5D4A2A"),
            Color.white
        ]
        return palette[abs(fallbackSeed) % palette.count]
    }
}

private enum OnboardingColors {
    static let card = Color.white.opacity(0.08)
    static let selectedCard = OVTheme.gold.opacity(0.18)
    static let border = Color.white.opacity(0.18)
    static let goldBorder = OVTheme.gold.opacity(0.95)
}

private enum OnboardingTypography {
    static func hero(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static let caption = Font.system(size: 11, weight: .semibold, design: .default)
}

private struct ReturningAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthSessionManager

    let store: SoulJourneyStore
    let onSignedIn: () -> Void

    @State private var helperText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(OVTheme.midnight)
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.92))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)

                Spacer()
                    .frame(height: 8)

                LogoMark(size: 74, cornerRadius: 18)
                    .padding(.bottom, 18)

                Text("One Visioon")
                    .font(OnboardingTypography.hero(30))
                    .foregroundStyle(OVTheme.midnight)

                Text("Grow closer to God through Scripture, reflection, and a clear path.")
                    .font(OnboardingTypography.body(16, weight: .semibold))
                    .foregroundStyle(OVTheme.ink.opacity(0.76))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 10)

                Spacer()

                VStack(spacing: 14) {
                    VStack(spacing: 6) {
                        Text("Welcome Back")
                            .font(OnboardingTypography.hero(26))
                            .foregroundStyle(OVTheme.midnight)

                        Text("Sign in to keep going.")
                            .font(OnboardingTypography.body(15, weight: .semibold))
                            .foregroundStyle(OVTheme.ink.opacity(0.72))
                            .multilineTextAlignment(.center)
                    }

                    SignInWithAppleButton(.continue) { request in
                        authManager.configureAppleRequest(request)
                    } onCompletion: { result in
                        Task {
                            await authManager.handleAppleSignIn(result: result, store: store)

                            if authManager.isSignedIn {
                                onSignedIn()
                                dismiss()
                            }
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 54)
                    .clipShape(Capsule())
                    .disabled(authManager.isAuthenticating)
                    .opacity(authManager.isAuthenticating ? 0.7 : 1)

                    if authManager.canStartGoogleSignIn {
                        GoogleAuthButton(
                            title: "Continue with Google",
                            isLoading: authManager.isAuthenticating
                        ) {
                            helperText = ""

                            Task {
                                await authManager.handleGoogleSignIn(store: store)

                                if authManager.isSignedIn {
                                    onSignedIn()
                                    dismiss()
                                }
                            }
                        }
                        .disabled(authManager.isAuthenticating)
                        .opacity(authManager.isAuthenticating ? 0.7 : 1)
                    } else {
                        helperTextView("Google sign-in and cloud sync unlock after Supabase config is added.", tint: OVTheme.gold)
                    }

                    if !helperText.isEmpty {
                        helperTextView(helperText, tint: OVTheme.gold)
                    }

                    if !authManager.errorMessage.isEmpty {
                        helperTextView(authManager.errorMessage, tint: OVTheme.coral)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
            .background(ReturningAccountBackground().ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private func helperTextView(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(OnboardingTypography.body(12, weight: .semibold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(tint.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ReturningAccountBackground: View {
    var body: some View {
        ZStack {
            OVTheme.paper

            Circle()
                .fill(.white.opacity(0.72))
                .frame(width: 320, height: 320)
                .blur(radius: 44)
                .offset(x: -130, y: -220)

            Circle()
                .fill(OVTheme.mist.opacity(0.85))
                .frame(width: 280, height: 280)
                .blur(radius: 54)
                .offset(x: 155, y: 280)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(store: SoulJourneyStore(), accessManager: SubscriptionAccessManager())
            .environmentObject(AuthSessionManager())
    }
}
