# Eatly – Personal Health and Nutrition Tracker

[🇹🇷 Türkçe README](README.tr.md)

Eatly is a mobile health and nutrition tracking application designed to help users build healthier habits. The app combines meal tracking, food photo analysis, water intake tracking, sports activity logging, calorie calculations, and personalized nutrition suggestions in a single Flutter-based mobile experience.

The project includes a Flutter mobile application and a separate FastAPI-based vision backend that can analyze food images and return labels or detected objects through an API endpoint.

## About the Project

Eatly focuses on making daily health tracking easier and more practical. Users can record meals, track calories and macronutrients, monitor their water intake, log workouts, and review daily or weekly progress. The application uses a service-based architecture with Supabase integration for authentication and data management.

The project is suitable for demonstrating mobile app development, backend integration, API usage, image analysis, user authentication, and health-related data tracking.

## Features

- **User Authentication**
  - Sign up and login flow
  - Password reset support
  - Onboarding and startup screens

- **Meal and Nutrition Tracking**
  - Add food items with portion information
  - Track calories, protein, carbohydrates, fat, fiber, vitamins, and minerals
  - Generate daily nutrition summaries
  - Compare daily totals with target calorie and macro goals

- **Food Photo Analysis**
  - Analyze food photos with a FastAPI vision backend
  - Supports image-byte upload through `/api/vision/analyze`
  - Optional query parameters such as `features=labels,objects` and `threshold`
  - Can be deployed with Docker and Hugging Face Spaces

- **Calorie and Energy Calculations**
  - Calculate BMR using user profile data
  - Estimate TDEE according to activity level
  - Support different health goals such as weight loss, maintenance, and muscle gain

- **Sports Activity Tracking**
  - Log activities such as running, walking, cycling, swimming, workout, yoga, HIIT, and other exercises
  - Estimate burned calories based on activity type and duration
  - Store activity history and retrieve recent or daily activities

- **Water Intake Tracking**
  - Add daily water intake in milliliters
  - Set and update daily water goals
  - View daily and weekly water consumption data

- **Insights and Suggestions**
  - Nutrition tips and healthy habit suggestions
  - Daily and weekly summary screens
  - Planned achievement and progress tracking features

- **Modern Mobile Architecture**
  - Flutter and Dart frontend
  - Supabase backend integration
  - Service-based code organization
  - Offline/sync-oriented service structure

## Tech Stack

| Technology | Purpose |
|-----------|---------|
| Flutter | Cross-platform mobile application development |
| Dart | Main programming language for the mobile app |
| Supabase | Authentication, database, and backend services |
| PowerSync | Offline-first synchronization support |
| FastAPI | Vision backend API |
| Hugging Face Transformers | Image analysis and AI model support |
| FatSecret API | Food recognition and nutrition data integration |
| Docker | Backend containerization |

## Project Structure

```text
eatly/
├── backend/                 # FastAPI vision backend
│   ├── app/                 # Backend application files
│   ├── Dockerfile           # Docker configuration
│   ├── requirements.txt     # Python dependencies
│   └── README.md            # Backend-specific documentation
│
├── eatly/                   # Flutter mobile application
│   ├── android/             # Android project files
│   ├── ios/                 # iOS project files
│   ├── lib/
│   │   ├── app/             # App setup, routing, dialogs, bottom sheets
│   │   ├── core/            # Models, services, config, theme, utilities
│   │   └── ui/              # Views and user interface components
│   └── pubspec.yaml         # Flutter dependencies
│
└── README.md
```

## Getting Started

### Prerequisites

Before running the mobile app, make sure you have:

- Flutter SDK installed
- Android Studio or Xcode configured
- A Supabase project
- Required API keys for Supabase, FatSecret, and/or Hugging Face if you want to use the analysis features

### Mobile App Setup

Clone the repository:

```bash
git clone https://github.com/dursunozer/eatly.git
cd eatly/eatly
```

Install Flutter dependencies:

```bash
flutter pub get
```

Configure your Supabase and API credentials in the related configuration files.

Run the app:

```bash
flutter run
```

Build for Android:

```bash
flutter build apk
```

Build for iOS:

```bash
flutter build ios
```

## Vision Backend Setup

Go to the backend folder:

```bash
cd backend
```

Install Python dependencies:

```bash
pip install -r requirements.txt
```

Run the backend locally:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 7860
```

The main endpoint is:

```http
POST /api/vision/analyze
```

Example Docker usage:

```bash
docker build -t eatly-vision .
docker run -p 7860:7860 eatly-vision
```

## Future Improvements

- More accurate food recognition results
- Improved nutrition database integration
- Barcode scanning support
- More detailed charts and statistics
- Achievement and badge system
- Multi-language support improvements
- Automated tests
- Improved error handling and API configuration

## Contributing

Contributions are welcome. To contribute:

```bash
git checkout -b feature/your-feature-name
git add .
git commit -m "feat: add your feature"
git push origin feature/your-feature-name
```

Then open a pull request.

## License

This repository currently does not include a license file. Please contact the repository owner before using or distributing the project for commercial purposes.

## Developer

**Dursun Özer**  
GitHub: [@dursunozer](https://github.com/dursunozer)
