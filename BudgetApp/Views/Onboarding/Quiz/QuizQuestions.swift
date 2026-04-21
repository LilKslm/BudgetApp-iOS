import Foundation

struct QuizOption: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let emoji: String?
}

struct QuizQuestion: Identifiable {
    let id: Int
    let prompt: String
    let subtitle: String?
    let options: [QuizOption]
}

/// Build an emoji string from one or more Unicode codepoints at runtime.
/// Using integer codepoints avoids any file-encoding issues with raw emoji literals.
private func emj(_ codepoints: UInt32...) -> String {
    var s = ""
    for cp in codepoints {
        if let scalar = Unicode.Scalar(cp) {
            s.unicodeScalars.append(scalar)
        }
    }
    return s
}

// Common codepoints
private let VS16: UInt32 = 0xFE0F  // variation selector: force emoji presentation

// TODO: marketing copy — wording approved at Phase 6 pre-launch review.
let quizQuestions: [QuizQuestion] = [
    QuizQuestion(
        id: 0,
        prompt: "How stressed are you about money right now?",
        subtitle: nil,
        options: [
            QuizOption(label: "Not at all", value: "none", emoji: emj(0x1F60C)),          // 😌
            QuizOption(label: "A little", value: "little", emoji: emj(0x1F610)),           // 😐
            QuizOption(label: "A lot", value: "a_lot", emoji: emj(0x1F62C)),               // 😬
            QuizOption(label: "Every single day", value: "daily", emoji: emj(0x1F630))     // 😰
        ]
    ),
    QuizQuestion(
        id: 1,
        prompt: "How many times have you tried to budget before?",
        subtitle: nil,
        options: [
            QuizOption(label: "This is my first time", value: "first", emoji: emj(0x1F44B)),       // 👋
            QuizOption(label: "Once or twice", value: "1_2", emoji: emj(0x270C, VS16)),            // ✌️
            QuizOption(label: "Three or more", value: "3_plus", emoji: emj(0x1F501))               // 🔁
        ]
    ),
    QuizQuestion(
        id: 2,
        prompt: "How do you track your spending today?",
        subtitle: nil,
        options: [
            QuizOption(label: "I don't", value: "none", emoji: emj(0x1F937)),                      // 🤷
            QuizOption(label: "In my head", value: "mental", emoji: emj(0x1F9E0)),                 // 🧠
            QuizOption(label: "Another app", value: "app", emoji: emj(0x1F4F1)),                   // 📱
            QuizOption(label: "Spreadsheet", value: "spreadsheet", emoji: emj(0x1F4CA))            // 📊
        ]
    ),
    QuizQuestion(
        id: 3,
        prompt: "What's your biggest budgeting frustration?",
        subtitle: "Pick the one that stings most.",
        options: [
            QuizOption(label: "Way too manual", value: "too_manual", emoji: emj(0x270D, VS16)),    // ✍️
            QuizOption(label: "Too complicated", value: "complicated", emoji: emj(0x1F92F)),       // 🤯
            QuizOption(label: "I never stick to it", value: "no_stick", emoji: emj(0x1F4A8)),      // 💨
            QuizOption(label: "Feels too restrictive", value: "restrictive", emoji: emj(0x1F512))  // 🔒
        ]
    ),
    QuizQuestion(
        id: 4,
        prompt: "What's your current savings cushion?",
        subtitle: nil,
        options: [
            QuizOption(label: "Less than $500", value: "under_500", emoji: emj(0x1F331)),          // 🌱
            QuizOption(label: "$500 to $2,000", value: "500_2k", emoji: emj(0x1F4B5)),             // 💵
            QuizOption(label: "$2,000 to $10,000", value: "2k_10k", emoji: emj(0x1F4B0)),          // 💰
            QuizOption(label: "$10,000+", value: "10k_plus", emoji: emj(0x1F3E6))                  // 🏦
        ]
    ),
    QuizQuestion(
        id: 5,
        prompt: "How about debt?",
        subtitle: nil,
        options: [
            QuizOption(label: "I'm debt-free!", value: "none", emoji: emj(0x1F389)),               // 🎉
            QuizOption(label: "Credit cards", value: "credit_cards", emoji: emj(0x1F4B3)),         // 💳
            QuizOption(label: "Student loans", value: "student_loans", emoji: emj(0x1F393)),       // 🎓
            QuizOption(label: "Multiple types", value: "multiple", emoji: emj(0x1F4CB))            // 📋
        ]
    ),
    QuizQuestion(
        id: 6,
        prompt: "Do you know where your subscriptions go?",
        subtitle: nil,
        options: [
            QuizOption(label: "I track every one", value: "all", emoji: emj(0x2705)),              // ✅
            QuizOption(label: "Most of them", value: "most", emoji: emj(0x1F50D)),                 // 🔍
            QuizOption(label: "A few, maybe?", value: "few", emoji: emj(0x1F914)),                 // 🤔
            QuizOption(label: "No idea", value: "none", emoji: emj(0x2753))                        // ❓
        ]
    ),
    QuizQuestion(
        id: 7,
        prompt: "What's your first savings goal?",
        subtitle: nil,
        options: [
            QuizOption(label: "Emergency fund", value: "emergency", emoji: emj(0x1F6DF)),          // 🛟
            QuizOption(label: "Vacation", value: "vacation", emoji: emj(0x2708, VS16)),            // ✈️
            QuizOption(label: "Home", value: "home", emoji: emj(0x1F3E1)),                         // 🏡
            QuizOption(label: "Car", value: "car", emoji: emj(0x1F697)),                           // 🚗
            QuizOption(label: "Something else", value: "other", emoji: emj(0x1F3AF))               // 🎯
        ]
    ),
    QuizQuestion(
        id: 8,
        prompt: "Do you share finances with someone?",
        subtitle: nil,
        options: [
            QuizOption(label: "Just me", value: "solo", emoji: emj(0x1F64B)),                      // 🙋
            QuizOption(label: "Partner", value: "partner", emoji: emj(0x1F46B)),                   // 👫
            QuizOption(label: "Roommate(s)", value: "roommates", emoji: emj(0x1F3E0))              // 🏠
        ]
    ),
    QuizQuestion(
        id: 9,
        prompt: "Rate your money confidence today.",
        subtitle: "1 = not at all confident, 5 = totally in control.",
        options: [
            QuizOption(label: "1 - Lost", value: "1", emoji: emj(0x1F635)),                        // 😵
            QuizOption(label: "2 - Struggling", value: "2", emoji: emj(0x1F613)),                  // 😓
            QuizOption(label: "3 - Getting there", value: "3", emoji: emj(0x1F60A)),               // 😊
            QuizOption(label: "4 - Doing well", value: "4", emoji: emj(0x1F4AA)),                  // 💪
            QuizOption(label: "5 - In control", value: "5", emoji: emj(0x1F3C6))                   // 🏆
        ]
    ),
    QuizQuestion(
        id: 10,
        prompt: "What's your main income source?",
        subtitle: nil,
        options: [
            QuizOption(label: "Regular salary", value: "salary", emoji: emj(0x1F4BC)),             // 💼
            QuizOption(label: "Hourly / part-time", value: "hourly", emoji: emj(0x23F0)),          // ⏰
            QuizOption(label: "Freelance / self-employed", value: "freelance", emoji: emj(0x1F4BB)), // 💻
            QuizOption(label: "Multiple streams", value: "multiple", emoji: emj(0x1F30A))          // 🌊
        ]
    ),
    QuizQuestion(
        id: 11,
        prompt: "Where does your unplanned spending usually go?",
        subtitle: nil,
        options: [
            QuizOption(label: "Food & drinks", value: "food", emoji: emj(0x1F355)),                // 🍕
            QuizOption(label: "Online shopping", value: "online", emoji: emj(0x1F4E6)),            // 📦
            QuizOption(label: "Entertainment / going out", value: "entertainment", emoji: emj(0x1F389)), // 🎉
            QuizOption(label: "It varies - hard to say", value: "varies", emoji: emj(0x1F937))     // 🤷
        ]
    ),
    QuizQuestion(
        id: 12,
        prompt: "How often do you check your bank balance?",
        subtitle: nil,
        options: [
            QuizOption(label: "Rarely or never", value: "rarely", emoji: emj(0x1F4F5)),            // 📵
            QuizOption(label: "A few times a month", value: "monthly", emoji: emj(0x1F4C5)),       // 📅
            QuizOption(label: "Every week", value: "weekly", emoji: emj(0x1F440)),                 // 👀
            QuizOption(label: "Almost every day", value: "daily", emoji: emj(0x1F4F1))             // 📱
        ]
    ),
    QuizQuestion(
        id: 13,
        prompt: "Do you have a monthly budget in mind?",
        subtitle: nil,
        options: [
            QuizOption(label: "No, I spend freely", value: "none", emoji: emj(0x1F30A)),           // 🌊
            QuizOption(label: "A rough number in my head", value: "rough", emoji: emj(0x1F4AD)),   // 💭
            QuizOption(label: "Yes, a specific number", value: "specific", emoji: emj(0x1F4DD)),   // 📝
            QuizOption(label: "Yes, and I track it actively", value: "active", emoji: emj(0x2705)) // ✅
        ]
    ),
    QuizQuestion(
        id: 14,
        prompt: "What does financial freedom mean to you?",
        subtitle: "Your answer shapes your plan.",
        options: [
            QuizOption(label: "Never worrying about bills", value: "no_stress", emoji: emj(0x1F60C)), // 😌
            QuizOption(label: "Traveling whenever I want", value: "travel", emoji: emj(0x2708, VS16)), // ✈️
            QuizOption(label: "Buying my dream home or car", value: "property", emoji: emj(0x1F3E1)), // 🏡
            QuizOption(label: "Retiring early", value: "retire", emoji: emj(0x1F3C4))              // 🏄
        ]
    )
]
