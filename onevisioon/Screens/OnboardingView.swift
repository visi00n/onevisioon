import SwiftUI

struct OnboardingView: View {
    @ObservedObject var store: SoulJourneyStore
    @ObservedObject var accessManager: SubscriptionAccessManager

    @State private var step = 0
    @State private var pulseBackground = false
    @State private var isAdvancing = true

    @State private var fullName = ""
    @State private var email = ""
    @State private var faithStage = ""
    @State private var biggestChallenge = ""
    @State private var scriptureRhythm = ""
    @State private var prayerRhythm = ""
    @State private var selectedVersion = ""
    @State private var selectedPremiumPlan = ""

    private struct ChoiceOption: Identifiable, Hashable {
        let id: String
        let title: String
        let detail: String?
    }

    private let faithStageOptions = [
        ChoiceOption(id: "lost", title: "Lost / unsure", detail: "Need a clear start."),
        ChoiceOption(id: "growing", title: "Trying to grow", detail: "Want to grow steadily."),
        ChoiceOption(id: "committed", title: "Fully committed", detail: "Ready to go deeper.")
    ]

    private let challengeOptions = [
        "Staying consistent",
        "Hearing God clearly",
        "Controlling thoughts",
        "Anxiety and peace",
        "Relationships and forgiveness",
        "Purpose and direction"
    ]

    private let rhythmOptions = [
        "Never",
        "A few times a week",
        "Most days",
        "Daily"
    ]

    private let freeBetaBullets = [
        "Read the full KJV Bible at your own pace",
        "Chapter lessons with reflection after each chapter",
        "Optional Discord community"
    ]
    private let premiumVersionBullets = [
        "Bible School lessons with deeper teaching and history",
        "Guided study paths",
        "20% of profits used to help people in need"
    ]

    var body: some View {
        ZStack {
            OVTheme.mainBackground.ignoresSafeArea()

            Circle()
                .fill(OVTheme.lemon.opacity(0.52))
                .frame(width: 300)
                .blur(radius: 36)
                .offset(x: 150, y: -250)
                .scaleEffect(pulseBackground ? 1.05 : 0.93)
                .animation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true), value: pulseBackground)

            Circle()
                .fill(OVTheme.sky.opacity(0.3))
                .frame(width: 280)
                .blur(radius: 38)
                .offset(x: -150, y: 320)
                .scaleEffect(pulseBackground ? 0.94 : 1.05)
                .animation(.easeInOut(duration: 4.8).repeatForever(autoreverses: true), value: pulseBackground)

            VStack(spacing: 14) {
                header

                ScrollView(showsIndicators: false) {
                    ZStack {
                        stepView
                            .id(step)
                            .transition(
                                .asymmetric(
                                    insertion: (isAdvancing ? AnyTransition.move(edge: .trailing) : AnyTransition.move(edge: .leading))
                                        .combined(with: .opacity),
                                    removal: (isAdvancing ? AnyTransition.move(edge: .leading) : AnyTransition.move(edge: .trailing))
                                        .combined(with: .opacity)
                                )
                            )
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.84), value: step)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                controls
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .onAppear {
            hydrateFromProfile(store.onboardingProfile)
            pulseBackground = true
        }
    }

    private var totalSteps: Int { 6 }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ONE VISIOON")
                        .font(OVTheme.heading(22))
                        .foregroundStyle(OVTheme.midnight)
                    Text(step == 0 ? "Welcome in..." : (step == totalSteps - 1 ? "Choose your path..." : "Building your path..."))
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }

                Spacer()

                Text("\(step + 1)/\(totalSteps)")
                    .font(OVTheme.heading(14))
                    .foregroundStyle(OVTheme.midnight.opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.85))
                    .clipShape(Capsule())
            }

            GeometryReader { proxy in
                let width = max(0, proxy.size.width)
                let progress = CGFloat(step + 1) / CGFloat(totalSteps)

                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.78))
                    Capsule().fill(OVTheme.midnight).frame(width: width * progress)
                }
            }
            .frame(height: 8)
        }
    }

    @ViewBuilder
    private var stepView: some View {
        switch step {
        case 0:
            introStep
        case 1:
            walkWithGodQuestion
        case 2:
            identityQuestion
        case 3:
            choiceQuestion(
                title: "What are you struggling with most?",
                subtitle: "",
                options: challengeOptions,
                selection: $biggestChallenge
            )
        case 4:
            rhythmQuestion
        default:
            finalStep
        }
    }

    private var introStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Read daily. Study deeply.")
                .font(OVTheme.display(42))
                .foregroundStyle(OVTheme.midnight)
                .lineSpacing(-2)
                .padding(.bottom, 4)

            onboardingInfoCard(
                title: "Studying the Bible",
                accent: OVTheme.midnight,
                bullets: freeBetaBullets
            )

            onboardingInfoCard(
                title: "Bible School",
                accent: OVTheme.gold,
                bullets: premiumVersionBullets
            )
        }
    }

    private var walkWithGodQuestion: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepTitle("Where are you in your walk with God?")

            ForEach(faithStageOptions) { option in
                choiceCard(
                    title: option.title,
                    detail: option.detail ?? "",
                    selected: faithStage == option.title
                ) {
                    faithStage = option.title
                }
            }
        }
    }

    private var identityQuestion: some View {
        VStack(alignment: .leading, spacing: 14) {
            stepTitle("Tell us about you")

            inputField(title: "Your name", text: $fullName, placeholder: "First name")

            inputField(
                title: "Newsletter email (optional)",
                text: $email,
                placeholder: "you@example.com",
                keyboardType: .emailAddress,
                autocapitalization: .never,
                disableAutocorrection: true
            )

            if !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isValidEmail {
                Text("Enter a valid email address.")
                    .font(OVTheme.body(13))
                    .foregroundStyle(.orange)
            }
        }
    }

    private var rhythmQuestion: some View {
        VStack(alignment: .leading, spacing: 14) {
            stepTitle("Your rhythm")

            selectionGroup(
                title: "Scripture rhythm",
                subtitle: "",
                options: rhythmOptions,
                selection: $scriptureRhythm
            )

            selectionGroup(
                title: "Prayer rhythm",
                subtitle: "",
                options: rhythmOptions,
                selection: $prayerRhythm
            )
        }
    }

    private var finalStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            stepTitle("Choose your study path")

            versionCard(
                title: "Studying the Bible",
                accent: OVTheme.midnight,
                bullets: freeBetaBullets,
                selected: selectedVersion == "free"
            ) {
                selectedVersion = "free"
                selectedPremiumPlan = ""
            }

            versionCard(
                title: "Bible School",
                accent: OVTheme.gold,
                bullets: premiumVersionBullets,
                selected: selectedVersion == "premium"
            ) {
                selectedVersion = "premium"
            }

            if selectedVersion == "premium" {
                Text("Bible School is unlocked in this build so you can test the full lesson and quest flow without stopping at membership.")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))
                    .padding(.top, 2)
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 10) {
            if accessManager.isMembershipEnabled, let message = accessManager.errorMessage {
                Text(message)
                    .font(OVTheme.body(13))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            Button {
                goForward()
            } label: {
                Text(primaryButtonTitle)
                    .font(OVTheme.heading(17))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
            }
            .disabled(!canContinue || accessManager.isPurchasing)
            .opacity((canContinue && !accessManager.isPurchasing) ? 1 : 0.45)
        }
    }

    private var primaryButtonTitle: String {
        guard step == totalSteps - 1 else { return "Continue" }
        if accessManager.isPurchasing {
            return "Starting Bible School..."
        }
        return selectedVersion == "premium" ? "Start Bible School" : "Start Studying the Bible"
    }

    private var canContinue: Bool {
        switch step {
        case 0:
            return true
        case 1:
            return !faithStage.isEmpty
        case 2:
            return !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && (trimmedEmail.isEmpty || isValidEmail)
        case 3:
            return !biggestChallenge.isEmpty
        case 4:
            return !scriptureRhythm.isEmpty && !prayerRhythm.isEmpty
        default:
            return !selectedVersion.isEmpty
        }
    }

    private func goForward() {
        guard canContinue else { return }
        accessManager.errorMessage = nil
        isAdvancing = true

        if step < totalSteps - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.84)) {
                step += 1
            }
            return
        }

        Task {
            await finishOnboarding()
        }
    }

    private func finishOnboarding() async {
        let profile = OnboardingAnswerSet(
            fullName: fullName,
            username: "",
            email: trimmedEmail,
            faithStage: faithStage,
            biggestChallenge: biggestChallenge,
            scriptureRhythm: scriptureRhythm,
            prayerRhythm: prayerRhythm,
            learningStyle: "",
            weeklyCommitment: "",
            reminderWindow: "",
            selectedVersion: selectedVersion,
            selectedPremiumPlan: selectedPremiumPlan
        )

        withAnimation(.spring(response: 0.4, dampingFraction: 0.84)) {
            store.completeOnboarding(profile: profile)
        }
    }

    private func hydrateFromProfile(_ profile: OnboardingAnswerSet) {
        fullName = profile.fullName
        email = profile.email
        faithStage = profile.faithStage
        biggestChallenge = profile.biggestChallenge
        scriptureRhythm = profile.scriptureRhythm
        prayerRhythm = profile.prayerRhythm
        selectedVersion = profile.selectedVersion
        selectedPremiumPlan = profile.selectedPremiumPlan
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isValidEmail: Bool {
        let value = trimmedEmail
        return value.contains("@") && value.contains(".")
    }

    private func choiceQuestion(
        title: String,
        subtitle: String,
        options: [String],
        selection: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .modifier(StepTitleModifier())

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(OVTheme.body(16))
                    .foregroundStyle(OVTheme.ink.opacity(0.74))
            }

            ForEach(options, id: \.self) { option in
                choiceCard(
                    title: option,
                    detail: "",
                    selected: selection.wrappedValue == option
                ) {
                    selection.wrappedValue = option
                }
            }
        }
    }

    private func selectionGroup(
        title: String,
        subtitle: String,
        options: [String],
        selection: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(OVTheme.heading(20))
                .foregroundStyle(OVTheme.ink)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.68))
            }

            ForEach(options, id: \.self) { option in
                choiceCard(
                    title: option,
                    detail: "",
                    selected: selection.wrappedValue == option
                ) {
                    selection.wrappedValue = option
                }
            }
        }
        .padding(18)
        .background(.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func choiceCard(
        title: String,
        detail: String,
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: detail.isEmpty ? 0 : 5) {
                    Text(title)
                        .font(OVTheme.heading(17))
                        .foregroundStyle(OVTheme.ink)
                    if !detail.isEmpty {
                        Text(detail)
                            .font(OVTheme.body(14))
                            .foregroundStyle(OVTheme.ink.opacity(0.7))
                    }
                }

                Spacer()

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(selected ? OVTheme.gold : OVTheme.ink.opacity(0.35))
            }
            .padding(16)
            .background(selected ? OVTheme.lemon.opacity(0.28) : .white.opacity(0.95))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? OVTheme.gold : .clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func inputField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .words,
        disableAutocorrection: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(OVTheme.heading(16))
                .foregroundStyle(OVTheme.ink)

            TextField(placeholder, text: text)
                .font(OVTheme.body(22))
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(disableAutocorrection)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(.white.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(OVTheme.midnight, lineWidth: 1.8)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private func stepTitle(_ text: String) -> some View {
        Text(text)
            .modifier(StepTitleModifier())
    }

    private func onboardingInfoCard(title: String, accent: Color, bullets: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(OVTheme.heading(18))
                .foregroundStyle(accent)

            ForEach(bullets, id: \.self) { item in
                bullet(item)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 174, alignment: .topLeading)
        .padding(18)
        .background(.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func versionCard(
        title: String,
        accent: Color,
        bullets: [String],
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(OVTheme.heading(18))
                        .foregroundStyle(accent)

                    Spacer()

                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(selected ? OVTheme.gold : OVTheme.ink.opacity(0.35))
                }

                ForEach(bullets, id: \.self) { item in
                    bullet(item)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 166, alignment: .topLeading)
            .padding(18)
            .background(selected ? OVTheme.lemon.opacity(0.18) : .white.opacity(0.95))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(selected ? OVTheme.gold : .clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func premiumPlanCard(
        title: String,
        price: String,
        cadence: String,
        selected: Bool,
        discountText: String?,
        highlightsPrice: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(OVTheme.heading(17))
                        .foregroundStyle(OVTheme.ink)
                    Spacer()
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(selected ? OVTheme.gold : OVTheme.ink.opacity(0.35))
                }

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(price)
                        .font(OVTheme.display(28))
                        .foregroundStyle(highlightsPrice ? Color(hex: "2D9C63") : OVTheme.midnight)
                    Text(cadence)
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.62))
                }

                if let discountText {
                    Text(discountText)
                        .font(OVTheme.heading(11))
                        .foregroundStyle(.red)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
            .padding(14)
            .background(selected ? OVTheme.lemon.opacity(0.18) : .white.opacity(0.95))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? OVTheme.gold : .clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(OVTheme.gold)
            Text(text)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.8))
        }
    }

    private func summaryRow(_ key: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text("\(key):")
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.ink)
            Text(value)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))
            Spacer()
        }
    }
}

private struct StepTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(OVTheme.heading(24))
            .foregroundStyle(OVTheme.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .allowsTightening(true)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(store: SoulJourneyStore(), accessManager: SubscriptionAccessManager())
    }
}
