# Moodlyy Application

A comprehensive mood tracking application built with Flutter and powered by AI, designed to help users record, analyze, and understand their emotional well-being over time.

## 🌟 Overview

Moodlyy is a full-stack mobile application that enables users to:

- **Track daily moods** with detailed emotional data
- **Visualize emotional patterns** through calendar views and statistics
- **Receive AI-powered insights** based on emotional history
- **Manage personal settings** with multi-language and theme support

The application consists of two main components:

- **Flutter Mobile App**: Cross-platform application (Android, iOS, Web, Windows, Linux, macOS)
- **AI Backend API**: FastAPI service with Google Gemini integration for generating emotional insights

## ✨ Features

### Core Features

- 📅 **Calendar View**: Visual calendar showing mood history with color-coded indicators
- 📊 **Statistics Dashboard**: Comprehensive analytics with bar charts and mood flow graphs
- 🤖 **AI Emotional Analysis**: Get personalized advice based on mood patterns (week/month/year)
- 🎨 **Mood Tracking**: Record daily emotions with:
  - 5 primary emotions (Very Sad, Sad, Neutral, Happy, Very Happy)
  - 15 secondary emotions (excited, relaxed, anxious, etc.)
  - Social context (family, friends, partner, lover, strangers, alone)
  - Personal notes
- 🌍 **Multi-language Support**: Vietnamese and English with user-specific language settings
- 🎭 **Theme Support**: Light/Dark mode with per-user preferences
- 🔐 **Authentication**: Secure user authentication via Supabase
- 📱 **Cross-platform**: Supports Android, iOS, Web, Windows, Linux, and macOS

### AI Features

- **Intelligent Analysis**: AI analyzes mood patterns using Google Gemini
- **Time-based Insights**: Get summaries and advice for weekly, monthly, or yearly periods
- **Multi-language Responses**: AI responses in Vietnamese or English based on user settings
- **Data Validation**: Input validation for month (1-12) and year (within last 5 years, not in future)

## 🏗️ Architecture

### Frontend (Flutter)

- **State Management**: Provider pattern with ViewModels
- **Navigation**: GoRouter for declarative routing
- **Dependency Injection**: Centralized DI configuration
- **Localization**: i18n support with ARB files
- **Architecture Pattern**: Feature-based modular architecture

### Backend (Python/FastAPI)

- **API Framework**: FastAPI with async support
- **AI Integration**: Google Gemini API for emotional analysis
- **Data Processing**: Pandas for data manipulation
- **Database**: Supabase (PostgreSQL) for data storage
- **Containerization**: Docker for deployment

## 📚 Tech Stack

### Frontend

- **Flutter** ^3.9.0
- **Provider** ^6.1.5+1 - State management
- **Supabase Flutter** ^2.10.0 - Backend services
- **GoRouter** ^16.2.1 - Navigation
- **FL Chart** ^1.1.0 - Data visualization
- **Table Calendar** ^3.2.0 - Calendar widget
- **Flutter Local Notifications** ^17.2.1 - Push notifications
- **Timezone** ^0.9.2 - Timezone handling
- **HTTP** ^1.5.0 - HTTP client

### Backend

- **FastAPI** - Web framework
- **Uvicorn** - ASGI server
- **Pandas** - Data processing
- **Google Generative AI** - Gemini AI integration
- **Supabase Python Client** - Database access
- **Python-dotenv** - Environment configuration

### Infrastructure

- **Supabase** - Backend-as-a-Service (Database, Auth)
- **Docker** - Containerization
- **Python 3.10** - Backend runtime

## 📁 Project Structure

```
moodlyy_application/
├── ai/                          # AI Backend Service
│   ├── api/
│   │   └── main.py             # FastAPI application
│   ├── data/
│   │   ├── fetch_data_from_supabase.py
│   │   ├── clean_data.py
│   │   ├── logs_raw.csv
│   │   └── logs_clean.csv
│   ├── model/
│   │   ├── prompt_template.py
│   │   └── generate_output.py
│   ├── utils/
│   │   └── date_utils.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── run_all_pipeline.py
│
├── lib/                         # Flutter Application
│   ├── app/
│   │   ├── app.dart            # Root app widget
│   │   ├── di.dart             # Dependency injection
│   │   └── root_router.dart   # Navigation configuration
│   ├── features/               # Feature modules
│   │   ├── ai/                # AI insights feature
│   │   ├── app/               # App-level features (theme, locale)
│   │   ├── auth/              # Authentication
│   │   ├── calendar/          # Calendar view
│   │   ├── mood/              # Mood tracking
│   │   ├── stats/             # Statistics dashboard
│   │   ├── settings/          # User settings
│   │   ├── user/              # User profile
│   │   └── main_shell/        # Main navigation shell
│   ├── common/
│   │   └── l10n_etx.dart     # Localization extensions
│   └── l10n/                  # Localization files
│
├── assets/                      # App assets
│   ├── emotion/               # Primary emotion icons
│   ├── anotheremotion/        # Secondary emotion icons
│   ├── people/                # Social context icons
│   └── images/                # App images
│
└── pubspec.yaml               # Flutter dependencies
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** ^3.9.0
- **Dart SDK** (included with Flutter)
- **Python** 3.10+
- **Docker** (for AI backend)
- **Supabase Account** (for backend services)

### Frontend Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd moodlyy_application
   ```

2. **Install Flutter dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Supabase**

   - Update `lib/main.dart` with your Supabase credentials:
     ```dart
     await Supabase.initialize(
       url: 'YOUR_SUPABASE_URL',
       anonKey: 'YOUR_SUPABASE_ANON_KEY',
     );
     ```

4. **Run the application**
   ```bash
   flutter run
   ```

### AI Backend Setup

1. **Navigate to AI directory**

   ```bash
   cd ai
   ```

2. **Create environment file**

   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your credentials:

   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_key
   GEMINI_API_KEY=your_gemini_api_key
   ```

3. **Build and run with Docker**

   ```bash
   docker build -t moodlyy-ai .
   docker run -p 8000:8000 --env-file .env moodlyy-ai
   ```

   Or run locally:

   ```bash
   pip install -r requirements.txt
   uvicorn ai.api.main:app --host 0.0.0.0 --port 8000
   ```

4. **Update Flutter app API endpoint**
   - In `lib/features/ai/presentation/ai_page.dart`, update:
     ```dart
     final uri = Uri.parse("http://YOUR_API_URL:8000/get-advice");
     ```

### Database Setup

The application uses Supabase with the following main table:

**moods table:**

- `id` (UUID, primary key)
- `user_id` (UUID, foreign key to auth.users)
- `day` (DATE)
- `emotion` (TEXT) - Primary emotion
- `another_emotions` (TEXT) - JSON array of secondary emotions
- `people` (TEXT) - JSON array of social contexts
- `note` (TEXT)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

## 🔧 Configuration

### Environment Variables

**Flutter App:**

- Supabase URL and keys are configured in `lib/main.dart`

**AI Backend (.env):**

```
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_service_key
GEMINI_API_KEY=your_google_gemini_api_key
```

### Localization

Supported languages are defined in `lib/l10n/`:

- `app_en.arb` - English
- `app_vi.arb` - Vietnamese

Add new languages by creating new ARB files and running:

```bash
flutter gen-l10n
```

## 📖 Usage

### Recording a Mood

1. Navigate to the calendar view
2. Tap the center mood button or select a date
3. Choose primary emotion (5 levels)
4. Select secondary emotions (optional)
5. Select social context (who you were with)
6. Add a note (optional)
7. Save the mood entry

### Viewing Statistics

1. Navigate to the Statistics tab
2. Choose time period (Month/Year)
3. View visualizations:
   - **Bar Chart**: Distribution of primary emotions
   - **Mood Flow Chart**: Trend line of emotional scores
   - **Total Count**: Number of mood entries

### Getting AI Insights

1. Navigate to the AI tab
2. Select time period:
   - **Week**: Last 7 days
   - **Month**: Select month and year (1-12, within last 5 years)
   - **Year**: Select year (within last 5 years, not in future)
3. Tap "Get Advice"
4. Review AI-generated summary and recommendations

### Settings

- **Language**: Change app language (Vietnamese/English)
- **Theme**: Switch between light and dark mode

## 🔌 API Documentation

### AI Backend Endpoints

#### `POST /refresh-data`

Refresh and clean mood data from Supabase.

**Request Body:**

```json
{
  "mode": "week" | "month" | "year",
  "month": 1-12 (optional),
  "year": YYYY (optional)
}
```

**Response:**

```json
{
  "message": "Đang làm sạch toàn bộ dữ liệu..."
}
```

#### `POST /get-advice`

Get AI-powered emotional insights.

**Request Body:**

```json
{
  "user": "user_id",
  "mode": "week" | "month" | "year",
  "month": 1-12 (optional, required for month mode),
  "year": YYYY (optional, required for month/year mode),
  "lan": "vn" | "eng"
}
```

**Response:**

```json
{
  "user": "user_id",
  "mode": "week",
  "month": null,
  "year": null,
  "language": "vn",
  "ai_output": "{\"summary\": \"...\", \"advice\": \"...\"}",
  "count": 7
}
```

## 🛠️ Development

### Running Tests

```bash
flutter test
```

### Building for Production

**Android:**

```bash
flutter build apk --release
```

**iOS:**

```bash
flutter build ios --release
```

**Web:**

```bash
flutter build web
```

### Code Structure

- **Feature-based Architecture**: Each feature is self-contained with:

  - `data/` - Data services and repositories
  - `presentation/` - UI components and pages
  - `vm/` - ViewModels for state management
  - `domain/` - Business logic and entities

- **Dependency Injection**: Configured in `lib/app/di.dart`

- **Navigation**: Routes defined in `lib/app/root_router.dart`

## 📝 Data Flow

1. **User records mood** → Saved to Supabase via MoodVM
2. **AI Backend fetches data** → `/refresh-data` endpoint triggers data fetch and cleaning
3. **User requests insights** → `/get-advice` endpoint:
   - Filters data by user, mode, and time period
   - Generates prompt with cleaned mood data
   - Calls Google Gemini API
   - Returns formatted summary and advice

## 🔒 Security

- User authentication handled by Supabase
- Row-level security policies enforce data isolation
- API keys stored in environment variables (never committed)
- HTTPS for all network communications

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is part of a university thesis project. All rights reserved.

## 👥 Authors

- Development Team - Moodlyy Application

## 🙏 Acknowledgments

- **Supabase** - Backend infrastructure
- **Google Gemini** - AI capabilities
- **Flutter Team** - Framework and tools
- **FastAPI** - Backend framework

## 📞 Support

For issues, questions, or contributions, please open an issue on the repository.

---

**Note**: This is a university thesis project. The application is designed for educational and demonstration purposes.
