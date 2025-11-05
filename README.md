# LearningJourney

**LearningJourney** is a beautifully designed iOS app that helps you stay consistent with your daily learning goals.  
It encourages focus, progress, and motivation — turning learning into a rewarding habit.


---

## 🚀 Features

### 📅 Daily Streak Tracking  
- Log learning days with a single tap.  
- Use **Freeze Days** when you need a short break (limited based on streak duration).  
- Automatic streak recalculation when adding or removing days.

### 🔄 Streak States  
- **Active:** Your streak is ongoing and being tracked daily.  
- **Completed:** You’ve achieved your target duration (Week / Month / Year).  
- **Expired:** Your streak ends if inactive for more than 32 hours.

### 🧭 User Interface  
- **Main View:**  
  - Displays a stylish calendar highlighting your progress.  
  - Includes buttons for editing goals and logging today’s activity.  
- **New Goal View:**  
  - Create a new **Learning Topic** and set your desired duration.  
  - Automatically resets when goals or durations change.

### 🧩 Extensions & Helpers  
- Utilities for testing like `Calendar.generateDates(forLastNDays:)`.  
- UI helpers such as `glassEffect()` and gradient-based styles for a polished look.

---

## 🛠️ Setup & Run

1. Open the project in **Xcode 15+**.  
2. Set the **iOS Deployment Target** to **iOS 17** (or higher).  
3. Build and run the app on a **Simulator** or **physical device**.  
4. You can also test multiple streak states using **SwiftUI Previews**:

```swift
// Example: Completed weekly streak
let completedManager = StreakViewModel(
    mockLearned: Set(Calendar.current.generateDates(forLastNDays: 7)),
    learningTopic: "Mathematics",
    duration: .week
)

MainView(manager: completedManager)
