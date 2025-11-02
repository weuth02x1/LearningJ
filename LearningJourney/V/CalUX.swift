//
//  CalUX.swift
//  LearningJourney
//
//  Created by شهد عبدالله القحطاني on 07/05/1447 AH.

import SwiftUI

// ======================================================
// MARK: - Theme & Sizes
// ======================================================
fileprivate enum CalUX {
    static let pageBG       = Color.black
    static let headerText   = Color.white.opacity(0.70)
    static let dayText      = Color.white
    static let mutedText    = Color.white.opacity(0.55)

    static let circle: CGFloat      = 50   // 50×50
    static let numeralFont: CGFloat = 19   // حجم رقم اليوم داخل الدائرة

    
    static let monthSpacing: CGFloat = 18
    static let weekVSpacing: CGFloat = 8
}

// ======================================================
// MARK: - Helpers
// ======================================================
fileprivate extension Calendar {
    func months(of year: Int) -> [Date] {
        (1...12).compactMap { date(from: DateComponents(year: year, month: $0, day: 1)) }
    }
}

// ======================================================
// MARK: - Glass Circle (clear, interactive)
// ======================================================
fileprivate struct GlassCircle: View {
    var body: some View {
        Circle()
            .fill(.ultraThinMaterial) // طبقة القلاس
            .overlay(
                Circle().stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.22), .white.opacity(0.06), .white.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            )
            .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
            .frame(width: CalUX.circle, height: CalUX.circle)
    }
}

// ======================================================
// MARK: - Public View (With Top Bar)
// ======================================================
 struct GlassCalendarView: View {
    // ربط بالـ StreakViewModel (مرَّر من MainView)
    @ObservedObject var manager: StreakViewModel

     var year: Int
     var onDayTap: (Date) -> Void

    @Environment(\.calendar) private var cal

    // يتم تهيئتها من الخارج؛ onDayTap افتراضي يساوي لا شيء
     init(
        manager: StreakViewModel,
        year: Int = Calendar.current.component(.year, from: Date()),
        onDayTap: @escaping (Date) -> Void = { _ in }
    ) {
        self.manager = manager
        self.year = year
        self.onDayTap = onDayTap
    }

    // نعيد ترتيب الشهور بحيث يبدأ من الشهر الحالي
    private var rotatedMonths: [Date] {
        let months = cal.months(of: year)
        let currentIndex = Calendar.current.component(.month, from: Date()) - 1
        guard months.indices.contains(currentIndex) else { return months }
        return Array(months[currentIndex...] + months[..<currentIndex])
    }

     var body: some View {
        VStack(spacing: 0) {
            TopBar(title: "All activities")

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: CalUX.monthSpacing) {
                    ForEach(rotatedMonths, id: \.self) { month in
                        MonthBlock(month: month,
                                   manager: manager,
                                   onDayTap: { date in
                                       // نمرّر الحدث للخارج (المكالمه يمكن أن تحدث تغييرات على الـ manager)
                                       onDayTap(date)
                                   })
                        Divider()
                            .background(CalUX.mutedText.opacity(0.25))
                            .padding(.horizontal, 8)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .background(CalUX.pageBG.ignoresSafeArea())
    }
}

// ======================================================
// MARK: - Top Bar (عنوان فقط — تقدر تربطه بالـ Navigation من MainView)
// ======================================================
fileprivate struct TopBar: View {
    var title: String

    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

// ======================================================
// MARK: - Weekday Header (SUN..SAT)
// ======================================================
fileprivate struct WeekdayHeader: View {
    var body: some View {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        let symbols = fmt.shortWeekdaySymbols.map { $0.uppercased() } // SUN MON ...

        return HStack(spacing: 0) {
            ForEach(symbols, id: \.self) { s in
                Text(s)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(CalUX.headerText)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// ======================================================
// MARK: - Month Block (Month starts at 1, no spillover)
// ======================================================
fileprivate struct MonthBlock: View {
    @Environment(\.calendar) private var cal

    let month: Date
    @ObservedObject var manager: StreakViewModel
    let onDayTap: (Date) -> Void

    private var title: String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return df.string(from: month)
    }

    /// كل أيام الشهر فقط (من 1 إلى آخر يوم)
    private var monthDays: [Date] {
        let firstOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: month))!
        let daysInMonth = cal.range(of: .day, in: .month, for: month)!.count

        return (0..<daysInMonth).compactMap {
            cal.date(byAdding: .day, value: $0, to: firstOfMonth)
        }
    }

    /// تقسيم أيام الشهر إلى أسابيع متتالية كل صف يحوي حتى 7 أيام (بدون إضافة أيام من شهر آخر)
    private var weeks: [[Date]] {
        var result: [[Date]] = []
        var i = 0
        while i < monthDays.count {
            let end = min(i + 7, monthDays.count)
            result.append(Array(monthDays[i..<end]))
            i = end
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // عنوان الشهر
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)

            Divider()
                .background(CalUX.mutedText.opacity(0.35))
                .padding(.horizontal, 12)

            WeekdayHeader()
                .padding(.horizontal, 10)
                .padding(.top, 4)

            // شبكة الأسابيع (بدون تمديد خارج الشهر)
            VStack(spacing: CalUX.weekVSpacing) {
                ForEach(weeks.indices, id: \.self) { i in
                    WeekRow(days: weeks[i], manager: manager, onDayTap: onDayTap)
                }
            }
            .padding(.horizontal, 6)
        }
    }
}

// ======================================================
// MARK: - Week Row (pads to 7 slots, blanks after end)
// ======================================================
fileprivate struct WeekRow: View {
    let days: [Date]            // 1..n (<= 7)
    @ObservedObject var manager: StreakViewModel
    let onDayTap: (Date) -> Void

    var body: some View {
        HStack(spacing: 0) {
            // نعرض الأيام المتوفرة
            ForEach(days, id: \.self) { day in
                DayCell(date: day,
                        isLearned: manager.learnedDates.contains(Calendar.current.startOfDay(for: day)),
                        isFreezed: manager.freezedDates.contains(Calendar.current.startOfDay(for: day)),
                        onTap: { onDayTap(day) })
                    .frame(maxWidth: .infinity)
            }

            // نكمّل بخانات فاضية حتى 7 للحفاظ على المحاذاة
            if days.count < 7 {
                ForEach(0..<(7 - days.count), id: \.self) { _ in
                    Color.clear
                        .frame(width: CalUX.circle, height: CalUX.circle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 2)
                }
            }
        }
    }
}

// ======================================================
// MARK: - Day Cell (All glass, interactive 50×50)
// ======================================================
fileprivate struct DayCell: View {
    @Environment(\.calendar) private var cal
    let date: Date
    let isLearned: Bool
    let isFreezed: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                GlassCircle() // دائرة قلاسي

                // Overlay coloring based on state
                if isLearned {
                    Circle()
                        .fill(Color.orange.opacity(0.75))
                        .frame(width: CalUX.circle, height: CalUX.circle)
                } else if isFreezed {
                    Circle()
                        .fill(Color.cyan.opacity(0.45))
                        .frame(width: CalUX.circle, height: CalUX.circle)
                }

                Text(dayString)
                    .font(.system(size: CalUX.numeralFont, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: CalUX.circle, height: CalUX.circle)
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2)
    }

    private var dayString: String { String(cal.component(.day, from: date)) }
}

// ======================================================
// MARK: - Preview
// ======================================================
struct GlassCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = StreakViewModel(duration: .week)
        GlassCalendarView(manager: vm, year: 2025) { date in
            print("tapped", date)
        }
        .environment(\.locale, Locale(identifier: "en_US_POSIX"))
        .previewLayout(.device)
    }
}
