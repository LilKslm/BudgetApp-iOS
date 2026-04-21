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

// TODO: marketing copy — wording approved at Phase 6 pre-launch review.
let quizQuestions: [QuizQuestion] = [
    QuizQuestion(
        id: 0,
        prompt: "How stressed are you about money right now?",
        subtitle: nil,
        options: [
            QuizOption(label: "Not at all", value: "none", emoji: "😌"),
            QuizOption(label: "A little", value: "little", emoji: "😐"),
            QuizOption(label: "A lot", value: "a_lot", emoji: "😬"),
            QuizOption(label: "Every single day", value: "daily", emoji: "😰")
        ]
    ),
    QuizQuestion(
        id: 1,
        prompt: "How many times have you tried to budget before?",
        subtitle: nil,
        options: [
            QuizOption(label: "This is my first time", value: "first", emoji: "👋"),
            QuizOption(label: "Once or twice", value: "1_2", emoji: "✌️"),
            QuizOption(label: "Three or more", value: "3_plus", emoji: "🔁")
        ]
    ),
    QuizQuestion(
        id: 2,
        prompt: "How do you track your spending today?",
        subtitle: nil,
        options: [
            QuizOption(label: "I don't", value: "none", emoji: "🤷"),
            QuizOption(label: "In my head", value: "mental", emoji: "🧠"),
            QuizOption(label: "Another app", value: "app", emoji: "📱"),
            QuizOption(label: "Spreadsheet", value: "spreadsheet", emoji: "📊")
        ]
    ),
    QuizQuestion(
        id: 3,
        prompt: "What's your biggest budgeting frustration?",
        subtitle: "Pick the one that stings most.",
        options: [
            QuizOption(label: "Way too manual", value: "too_manual", emoji: "✍️"),
            QuizOption(label: "Too complicated", value: "complicated", emoji: "🤯"),
            QuizOption(label: "I never stick to it", value: "no_stick", emoji: "💨"),
            QuizOption(label: "Feels too restrictive", value: "restrictive", emoji: "🔒")
        ]
    ),
    QuizQuestion(
        id: 4,
        prompt: "What's your current savings cushion?",
        subtitle: nil,
        options: [
            QuizOption(label: "Less than $500", value: "under_500", emoji: "🌱"),
            QuizOption(label: "$500 – $2,000", value: "500_2k", emoji: "💵"),
            QuizOption(label: "$2,000 – $10,000", value: "2k_10k", emoji: "💰"),
            QuizOption(label: "$10,000+", value: "10k_plus", emoji: "🏦")
        ]
    ),
    QuizQuestion(
        id: 5,
        prompt: "How about debt?",
        subtitle: nil,
        options: [
            QuizOption(label: "I'm debt-free 🎉", value: "none", emoji: nil),
            QuizOption(label: "Credit cards", value: "credit_cards", emoji: "💳"),
            QuizOption(label: "Student loans", value: "student_loans", emoji: "🎓"),
            QuizOption(label: "Multiple types", value: "multiple", emoji: "📋")
        ]
    ),
    QuizQuestion(
        id: 6,
        prompt: "Do you know where your subscriptions go?",
        subtitle: nil,
        options: [
            QuizOption(label: "I track every one", value: "all", emoji: "✅"),
            QuizOption(label: "Most of them", value: "most", emoji: "🔍"),
            QuizOption(label: "A few, maybe?", value: "few", emoji: "🤔"),
            QuizOption(label: "No idea", value: "none", emoji: "❓")
        ]
    ),
    QuizQuestion(
        id: 7,
        prompt: "What's your first savings goal?",
        subtitle: nil,
        options: [
            QuizOption(label: "Emergency fund", value: "emergency", emoji: "🛟"),
            QuizOption(label: "Vacation", value: "vacation", emoji: "✈️"),
            QuizOption(label: "Home", value: "home", emoji: "🏡"),
            QuizOption(label: "Car", value: "car", emoji: "🚗"),
            QuizOption(label: "Something else", value: "other", emoji: "🎯")
        ]
    ),
    QuizQuestion(
        id: 8,
        prompt: "Do you share finances with someone?",
        subtitle: nil,
        options: [
            QuizOption(label: "Just me", value: "solo", emoji: "🙋"),
            QuizOption(label: "Partner", value: "partner", emoji: "👫"),
            QuizOption(label: "Roommate(s)", value: "roommates", emoji: "🏠")
        ]
    ),
    QuizQuestion(
        id: 9,
        prompt: "Rate your money confidence today.",
        subtitle: "1 = not at all confident, 5 = totally in control.",
        options: [
            QuizOption(label: "1 — Lost", value: "1", emoji: "😵"),
            QuizOption(label: "2 — Struggling", value: "2", emoji: "😓"),
            QuizOption(label: "3 — Getting there", value: "3", emoji: "😊"),
            QuizOption(label: "4 — Doing well", value: "4", emoji: "💪"),
            QuizOption(label: "5 — In control", value: "5", emoji: "🏆")
        ]
    )
]
