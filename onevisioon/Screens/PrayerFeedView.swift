import SwiftUI

struct PrayerFeedView: View {
    @ObservedObject var store: SoulJourneyStore

    @State private var topic = ""
    @State private var message = ""
    @State private var showContent = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                        .stagedReveal(showContent, delay: 0.02)
                    composeCard
                        .stagedReveal(showContent, delay: 0.08)
                    postsSection
                        .stagedReveal(showContent, delay: 0.14)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Prayer Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AppInfoButton()
                }
            }
            .onAppear {
                guard !showContent else { return }
                showContent = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily")
                .font(OVTheme.display(36))
                .foregroundStyle(OVTheme.midnight)
            Text("community prayer")
                .font(OVTheme.heading(34))
                .foregroundStyle(OVTheme.ink)

            Text("Share requests and pray with other believers daily.")
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var composeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Share a prayer request")
                .font(OVTheme.heading(21))
                .foregroundStyle(OVTheme.ink)

            TextField("Topic (family, work, health...)", text: $topic)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $message)
                .font(OVTheme.body(15))
                .frame(minHeight: 96)
                .padding(8)
                .background(OVTheme.smoke)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                    store.addPrayerPost(topic: topic, message: message)
                    topic = ""
                    message = ""
                }
            } label: {
                Text("Post to Prayer Feed")
                    .font(OVTheme.heading(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
            }
            .disabled(topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var postsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Community posts")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            ForEach(store.sortedPrayerFeedPosts) { post in
                postCard(post)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.spring(response: 0.34, dampingFraction: 0.86), value: store.sortedPrayerFeedPosts)
    }

    private func postCard(_ post: PrayerFeedPost) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(OVTheme.heading(15))
                        .foregroundStyle(OVTheme.ink)
                    Text("\(post.handle) • \(relativeDate(post.createdAt))")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.56))
                }
                Spacer()
                Text(post.prayerTopic.uppercased())
                    .font(OVTheme.body(10))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(OVTheme.sky.opacity(0.45))
                    .clipShape(Capsule())
            }

            Text(post.message)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.8))

            Button {
                store.toggleAmen(for: post.id)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: post.didAmen ? "hands.sparkles.fill" : "hands.sparkles")
                    Text(post.didAmen ? "Prayed (\(post.amens))" : "Pray (\(post.amens))")
                        .font(OVTheme.body(13))
                }
                .foregroundStyle(post.didAmen ? .green : OVTheme.midnight)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(post.didAmen ? Color.green.opacity(0.12) : OVTheme.smoke)
                .clipShape(Capsule())
                .animation(.easeInOut(duration: 0.22), value: post.didAmen)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}

struct PrayerFeedView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerFeedView(store: SoulJourneyStore())
    }
}
