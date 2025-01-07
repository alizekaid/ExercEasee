
# Exerc-Ease: An Injury-Specific Exercise Application

Exerc-Ease is a cross-platform mobile application designed to assist individuals recovering from injuries. By providing personalized exercise plans based on pain levels and injury severity, the app empowers users to manage their recovery process safely and effectively. The application incorporates GIF-based demonstrations, progress tracking, and tailored recommendations with the guidance of consultants who are physiotherapists.

---

## Table of Contents
- [Introduction](#introduction)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)
- [Getting Started](#getting-started)
- [How It Works](#how-it-works)
- [Doctor Panel](#doctor-panel)
- [Expected Challenges](#expected-challenges)
- [Contributors](#contributors)
- [License](#license)

---

## Introduction
Recovering from an injury can be challenging, especially when the exercises are not tailored to individual needs. Misinformation or generic routines may worsen the condition or slow recovery. Exerc-Ease addresses this problem by offering a user-friendly mobile solution for injury-specific exercises, supporting safe rehabilitation for various body parts and injury types.

### Problem Statement
Many people struggle to find exercises that are safe and effective for their injury. Generic exercise routines may lead to further damage when not tailored to the injury type or severity.

### Objectives
- Provide exercises supported by GIFs tailored to the injury type and pain level.
- Enable users to track multiple injuries and monitor progress over time.
- Simplify the rehabilitation process with an intuitive and engaging UI.

---

## Key Features
1. **Injury Assessment**
   - Users input their injury type and pain level (1-3 scale) to receive a personalized exercise plan.
   - Two modes for creating injury records:
     - **Diagnosed Mode**: Users select their injury type from a predefined list.
     - **Body-Part-Based Mode**: Users select the injured body part via an interactive body figure.

2. **Exercise Recommendations**
   - Displays exercise GIFs relevant to the injury for proper guidance.
   - Exercises are stored securely in Firestore.

3. **Progress Tracking**
   - Monitors recovery progress with incremental updates (e.g., 7% for every 26 minutes of exercise).
   - Progress data is stored in Firestore and synced with the app’s interface.

4. **Pain Level Adjustment**
   - Users can modify their pain level over time to receive updated exercise plans.

5. **Multiple Injury Support**
   - Users can manage and track multiple injury records concurrently.

6. **Account Management**
   - Users can create accounts, log in (including Google Sign-In), and manage profiles securely.

7. **Notifications and Reminders**
   - Users takes notifications from their doctors about their current progress.

---

## Technology Stack
### Frontend
- **Flutter**: A powerful open-source UI toolkit for creating natively compiled applications for Android and iOS from a single codebase.
- **Dart**: Flutter's programming language for building robust app functionality.

### Backend
- **Flask**: A lightweight Python web framework used to build the backend API for the app. It handles interactions between the mobile application and the databases, including the retrieval of exercise data and GIFs.
- **Firestore**: Cloud-based database for managing user credentials, exercise data, progress levels, and injury records.
- **AWS-Hosted MySQL**: Stores GIF-related data and injury-specific guidelines.
- **Backend API**:Flask-based API hosted on AWS for fetching GIFs and managing database interactions.

### Platform Support
- Android
---

## Getting Started
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/exerc-ease.git
   cd exerc-ease
2. **Install Dependencies**: Ensure you have Flutter installed, then run:
```bash
flutter pub get
```
3. **Run the App**:
```bash
flutter run
```
4. **Setup Backend**:
-  Configure the AWS server for MySQL and API endpoints.
-   Ensure Firestore credentials are correctly set up in the app.

## How It Works
### User Workflow:
-   **Sign-Up/Login**: Users create an account or log in with Google.
-   **Injury Record Creation**:
    -   **Diagnosed Mode**: Select from a predefined list of injuries.
    -   **Body-Part-Based Mode**: Choose the injured body part and pain level.
-   **Exercise Recommendations**: View and follow GIF-based exercises.
-   **Progress Tracking**: Monitor recovery through progress updates.

### Backend Workflow:
  - User data, injury records, and progress levels are stored in Firestore.
 - Exercise data and GIFs are fetched from the MySQL server via the backend API.
   
### Progress Updates

- Every minute spent on exercises updates recovery progress by 0.26%, syncing with Firestore.

## Doctor Panel

In addition to the features available to users, Exerc-Ease includes a **Doctor Panel** designed for healthcare professionals. Doctors can monitor the injuries of users, track their progress, and send notifications tailored to specific injury types.

-   **Specialized Doctors**: Each doctor can only monitor users with injuries in their specialty. For example, a doctor specialized in shoulder injuries can monitor only users with shoulder injuries.
-   **Admin Account**: An admin account is required to create and assign doctor accounts. Doctors cannot create their own accounts, and their access is limited to their specific field of expertise.
-   **Notifications**: Doctors can send notifications to users about their recovery progress, which users can monitor within the app.
- 
## Expected Challenges

-   Ensuring accurate exercise recommendations for various injuries.
-   Managing scalable and secure backend infrastructure.
-   Validating exercises for safety and effectiveness across different injury severities.