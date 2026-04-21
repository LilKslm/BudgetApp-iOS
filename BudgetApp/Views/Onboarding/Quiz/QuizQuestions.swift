import Foundation

struct QuizOption: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let icon: String?
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
            QuizOption(label: "Not at all", value: "none", icon: "leaf.fill"),
            QuizOption(label: "A little", value: "little", icon: "cloud.fill"),
            QuizOption(label: "A lot", value: "a_lot", icon: "exclamationmark.triangle.fill"),
            QuizOption(label: "Every single day", value: "daily", icon: "cloud.bolt.rain.fill")
        ]
    ),
    QuizQuestion(
        id: 1,
        prompt: "How many times have you tried to budget before?",
        subtitle: nil,
        options: [
            QuizOption(label: "This is my first time", value: "first", icon: "sparkles"),
            QuizOption(label: "Once or twice", value: "1_2", icon: "arrow.clockwise"),
            QuizOption(label: "Three or more", value: "3_plus", icon: "arrow.triangle.2.circlepath")
        ]
    ),
    QuizQuestion(
        id: 2,
        prompt: "How do you track your spending today?",
        subtitle: nil,
        options: [
            QuizOption(label: "I don't", value: "none", icon: "xmark.circle.fill"),
            QuizOption(label: "In my head", value: "mental", icon: "brain.head.profile"),
            QuizOption(label: "Another app", value: "app", icon: "iphone"),
            QuizOption(label: "Spreadsheet", value: "spreadsheet", icon: "tablecells.fill")
        ]
    ),
    QuizQuestion(
        id: 3,
        prompt: "What's your biggest budgeting frustration?",
        subtitle: "Pick the one that stings most.",
        options: [
            QuizOption(label: "Way too manual", value: "too_manual", icon: "pencil.and.list.clipboard"),
            QuizOption(label: "Too complicated", value: "complicated", icon: "questionmark.app.fill"),
            QuizOption(label: "I never stick to it", value: "no_stick", icon: "wind"),
            QuizOption(label: "Feels too restrictive", value: "restrictive", icon: "lock.fill")
        ]
    ),
    QuizQuestion(
        id: 4,
        prompt: "What's your current savings cushion?",
        subtitle: nil,
        options: [
            QuizOption(label: "Less than $500", value: "under_500", icon: "leaf"),
            QuizOption(label: "$500 to $2,000", value: "500_2k", icon: "banknote.fill"),
            QuizOption(label: "$2,000 to $10,000", value: "2k_10k", icon: "dollarsign.circle.fill"),
            QuizOption(label: "$10,000+", value: "10k_plus", icon: "building.columns.fill")
        ]
    ),
    QuizQuestion(
        id: 5,
        prompt: "How about debt?",
        subtitle: nil,
        options: [
            QuizOption(label: "I'm debt-free!", value: "none", icon: "party.popper.fill"),
            QuizOption(label: "Credit cards", value: "credit_cards", icon: "creditcard.fill"),
            QuizOption(label: "Student loans", value: "student_loans", icon: "graduationcap.fill"),
            QuizOption(label: "Multiple types", value: "multiple", icon: "list.bullet.clipboard.fill")
        ]
    ),
    QuizQuestion(
        id: 6,
        prompt: "Do you know where your subscriptions go?",
        subtitle: nil,
        options: [
            QuizOption(label: "I track every one", value: "all", icon: "checkmark.seal.fill"),
            QuizOption(label: "Most of them", value: "most", icon: "magnifyingglass"),
            QuizOption(label: "A few, maybe?", value: "few", icon: "questionmark.bubble.fill"),
            QuizOption(label: "No idea", value: "none", icon: "questionmark.circle.fill")
        ]
    ),
    QuizQuestion(
        id: 7,
        prompt: "What's your first savings goal?",
        subtitle: nil,
        options: [
            QuizOption(label: "Emergency fund", value: "emergency", icon: "cross.case.fill"),
            QuizOption(label: "Vacation", value: "vacation", icon: "airplane"),
            QuizOption(label: "Home", value: "home", icon: "house.fill"),
            QuizOption(label: "Car", value: "car", icon: "car.fill"),
            QuizOption(label: "Something else", value: "other", icon: "target")
        ]
    ),
    QuizQuestion(
        id: 8,
        prompt: "Do you share finances with someone?",
        subtitle: nil,
        options: [
            QuizOption(label: "Just me", value: "solo", icon: "person.fill"),
            QuizOption(label: "Partner", value: "partner", icon: "person.2.fill"),
            QuizOption(label: "Roommate(s)", value: "roommates", icon: "person.3.fill")
        ]
    ),
    QuizQuestion(
        id: 9,
        prompt: "Rate your money confidence today.",
        subtitle: "1 = not at all confident, 5 = totally in control.",
        options: [
            QuizOption(label: "1 - Lost", value: "1", icon: "cloud.bolt.fill"),
            QuizOption(label: "2 - Struggling", value: "2", icon: "cloud.rain.fill"),
            QuizOption(label: "3 - Getting there", value: "3", icon: "face.smiling"),
            QuizOption(label: "4 - Doing well", value: "4", icon: "bolt.fill"),
            QuizOption(label: "5 - In control", value: "5", icon: "trophy.fill")
        ]
    ),
    QuizQuestion(
        id: 10,
        prompt: "What's your main income source?",
        subtitle: nil,
        options: [
            QuizOption(label: "Regular salary", value: "salary", icon: "briefcase.fill"),
            QuizOption(label: "Hourly / part-time", value: "hourly", icon: "clock.fill"),
            QuizOption(label: "Freelance / self-employed", value: "freelance", icon: "laptopcomputer"),
            QuizOption(label: "Multiple streams", value: "multiple", icon: "water.waves")
        ]
    ),
    QuizQuestion(
        id: 11,
        prompt: "Where does your unplanned spending usually go?",
        subtitle: nil,
        options: [
            QuizOption(label: "Food & drinks", value: "food", icon: "fork.knife"),
            QuizOption(label: "Online shopping", value: "online", icon: "shippingbox.fill"),
            QuizOption(label: "Entertainment / going out", value: "entertainment", icon: "party.popper.fill"),
            QuizOption(label: "It varies - hard to say", value: "varies", icon: "questionmark.circle.fill")
        ]
    ),
    QuizQuestion(
        id: 12,
        prompt: "How often do you check your bank balance?",
        subtitle: nil,
        options: [
            QuizOption(label: "Rarely or never", value: "rarely", icon: "eye.slash.fill"),
            QuizOption(label: "A few times a month", value: "monthly", icon: "calendar"),
            QuizOption(label: "Every week", value: "weekly", icon: "eye.fill"),
            QuizOption(label: "Almost every day", value: "daily", icon: "iphone")
        ]
    ),
    QuizQuestion(
        id: 13,
        prompt: "Do you have a monthly budget in mind?",
        subtitle: nil,
        options: [
            QuizOption(label: "No, I spend freely", value: "none", icon: "water.waves"),
            QuizOption(label: "A rough number in my head", value: "rough", icon: "cloud.fill"),
            QuizOption(label: "Yes, a specific number", value: "specific", icon: "pencil.and.list.clipboard"),
            QuizOption(label: "Yes, and I track it actively", value: "active", icon: "checkmark.seal.fill")
        ]
    ),
    QuizQuestion(
        id: 14,
        prompt: "What does financial freedom mean to you?",
        subtitle: "Your answer shapes your plan.",
        options: [
            QuizOption(label: "Never worrying about bills", value: "no_stress", icon: "leaf.fill"),
            QuizOption(label: "Traveling whenever I want", value: "travel", icon: "airplane"),
            QuizOption(label: "Buying my dream home or car", value: "property", icon: "house.fill"),
            QuizOption(label: "Retiring early", value: "retire", icon: "figure.surfing")
        ]
    )
]
