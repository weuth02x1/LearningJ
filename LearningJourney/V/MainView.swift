//
//  MainView.swift
//  LearningJourney
//
//  Created by شهد عبدالله القحطاني on 07/05/1447 AH.
//
import SwiftUI


struct MainView: View {
    @State private var learnedState: LearnedState = .notLearned
    @State private var isFreezeButtonPressed = false
    
    @StateObject var manager: StreakViewModel
    @Binding var showMonthPicker: Bool
    @State private var showCalendar = false
    @State private var showEdit = false

    enum LearnedState { case notLearned, learned, freezed, expired, completed }

    init(manager: StreakViewModel = StreakViewModel(duration: .week),
         showMonthPicker: Binding<Bool> = .constant(false)) {
        _showMonthPicker = showMonthPicker
        _manager = StateObject(wrappedValue: manager)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                contentView
            }
            .navigationBarBackButtonHidden(true)
            
            NavigationLink(destination: GlassCalendarView(manager: manager), isActive: $showCalendar) { EmptyView() }
            NavigationLink(isActive: $showEdit) {
                NewGoalView(manager: manager,
                            learningTopic: manager.learningTopic,
                            initialPeriod: manager.stringFromDuration(manager.duration))
                .navigationBarBackButtonHidden(true)
            } label: { EmptyView() }
        }
        .onAppear { updateLearnedState() }
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 18) {
            // 🏷️ الجزء العلوي: تايتل + أزرار + كارد
            HStack(spacing: 16) {
                Text("Activity")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Spacer()
                Button(action: { showCalendar = true }) {
                    Image(systemName: "calendar")
                        .foregroundColor(.white)
                        .padding()
                        .glassEffect()
                        .clipShape(Capsule())
                }
                Button(action: { showEdit = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.white)
                        .padding()
                        .glassEffect()
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 30)
            
            CalendarCardView(manager: manager, learningTopic: manager.learningTopic)
            
            // 🏷️ المحتوى السفلي حسب حالة الستريك
            switch determineStreakState() {
            case .expired:
                expiredBottom
            case .completed:
                completedBottom
            default:
                normalBottom
            }
            
            Spacer()
        }
        .padding(.top, 20)
    }

    // ✅ الأسفل للحالات المختلفة
    private var expiredBottom: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.largeTitle.bold())
                .padding(20)

                  Text("Your streak has ended!")
                .foregroundColor(.white)
                .font(.title.bold())
            Text("Don't worry, start a new goal to keep learning.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            newGoalSection
        }
    }

    private var completedBottom: some View {
        VStack(spacing: 20) {
            
            Image(systemName: "hands.and.sparkles.fill")
                .foregroundColor(.orange)
                .font(.largeTitle.bold())
                .padding(20)
                
            Text("Well Done!")
                .foregroundColor(.white)
                .font(.title.bold())
            Text("Goal completed! start learning again or set new learning goal")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .fixedSize(horizontal: false, vertical: true)
            newGoalSection
        }
    }

    private var normalBottom: some View {
        VStack(spacing: 18) {
            Button(action: handleCircleTap) {
                ZStack {
                    Circle()
                        .fill(bigCircleFill(for: learnedState))
                        .overlay(Circle().stroke(bigCircleStroke(for: learnedState), lineWidth: 1.5))
                        .frame(width: 270, height: 270)
                    
                    Text(bigCircleTitle(for: learnedState))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(bigCircleText(for: learnedState))
                        .multilineTextAlignment(.center)
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 25)
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isFreezeButtonPressed.toggle() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isFreezeButtonPressed = false
                    manager.toggleFreeze()
                    learnedState = .freezed
                }
            } label: {
                Text("Log as Freezed")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 300)
                    .padding(.vertical, 14)
                    .background(isFreezeButtonPressed ? Gradients.freezePressed : Gradients.freezeNormal)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Gradients.capsuleStroke, lineWidth: 1.2))
            }
            .disabled(manager.isFreezeDisabled)
            .opacity(manager.isFreezeDisabled ? 0.5 : 1)
            
            Text("\(manager.freezesUsed) out of \(manager.maxFreezes) Freezes used")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .padding(.bottom, 6)
        }
    }

    private var newGoalSection: some View {
        VStack(spacing: 10) {
            Button("Set new learning goal") { showEdit = true }
                .frame(width: 200, height: 48)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .glassEffect(.clear.tint(Color(hex: "#FF9230").opacity(0.9)))
                .clipShape(Capsule())
                .padding(.top, 20)
            Button(action: {
                   // إعادة تعيين المدة بدون تغيير الموضوع
                   manager.resetStreak()
               }) {
                   Text("Start learning again")
                       .padding(.top, 10)
                       .foregroundColor(.orange)
                       .frame(maxWidth: .infinity)
                       .multilineTextAlignment(.center)
               }        }
        .padding(.top, 25)
    }

    // MARK: - Actions
    private func updateLearnedState() {
        let today = Calendar.current.startOfDay(for: Date())
        if manager.freezedDates.contains(today) {
            learnedState = .freezed
        } else if manager.learnedDates.contains(today) {
            learnedState = .learned
        } else {
            learnedState = .notLearned
        }
    }

    private func handleCircleTap() {
        let today = Calendar.current.startOfDay(for: Date())
        guard !manager.freezedDates.contains(today),
              !manager.learnedDates.contains(today) else { return }
        manager.markAsLearned()
        updateLearnedState()
    }

    private func determineStreakState() -> LearnedState {
        if manager.isStreakExpired { return .expired }
        if manager.isStreakCompleted { return .completed }
        return learnedState
    }

    // MARK: - Styles
    private func bigCircleFill(for state: LearnedState) -> LinearGradient {
        switch state {
        case .notLearned: return Gradients.learnDefault
        case .learned: return Gradients.learned
        case .freezed: return Gradients.freezed
        default: return Gradients.learnDefault
        }
    }

    private func bigCircleStroke(for state: LearnedState) -> LinearGradient {
        switch state {
        case .notLearned: return Gradients.strokeDefault
        case .learned: return Gradients.strokeLearned
        case .freezed: return Gradients.strokeFreezed
        default: return Gradients.strokeDefault
        }
    }

    private func bigCircleText(for state: LearnedState) -> Color {
        switch state {
        case .notLearned: return .white
        case .learned: return .orange
        case .freezed: return Color(red: 0/255, green: 210/255, blue: 224/255)
        default: return .white
        }
    }

    private func bigCircleTitle(for state: LearnedState) -> String {
        switch state {
        case .notLearned: return "Log as\nLearned"
        case .learned: return "Learned\nToday"
        case .freezed: return "Day\nFreezed"
        default: return ""
        }
    }
}

extension Calendar {
    /// توليد مصفوفة من التواريخ بدءًا من اليوم وحتى الأيام السابقة بعدد n
    func generateDates(forLastNDays n: Int) -> [Date] {
        var dates: [Date] = []
        for i in 0..<n {
            if let date = self.date(byAdding: .day, value: -i, to: Date()) {
                dates.append(self.startOfDay(for: date))
            }
        }
        return dates
    }
}


#Preview {
    // ستريك مكتمل
    let completedManager = StreakViewModel(
        mockLearned: Set(Calendar.current.generateDates(forLastNDays: 7)),
        learningTopic: "Math",
        duration: .week
    )
    
    // ستريك منتهي
    let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
    let thirtyThreeHoursAgo = Calendar.current.date(byAdding: .hour, value: -33, to: Date())!
    let expiredManager = StreakViewModel(
        mockLearned: [twoDaysAgo],
        learningTopic: "Math",
        duration: .week,
        lastLogged: thirtyThreeHoursAgo
    )
    
    // عرض واحد للـ Preview (يمكن التبديل بينهما)
    MainView()
}
