# 5520_group44_ios

## Setup Instructions
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```


## Firebase Setup Instructions

This project uses Firebase for backend services. The `GoogleService-Info.plist` file is required for Firebase to work properly.

### Steps to Add the `GoogleService-Info.plist` File
1. Obtain the `GoogleService-Info.plist` file from the project administrator or team lead. This file cannot be included in the public repository for security reasons.
2. Place the file in the root directory (5520_Group44 folder) of the Xcode project.
3. Add the file to the project in Xcode:
   - Drag and drop the `GoogleService-Info.plist` file into the Xcode project navigator (usually the left pane in Xcode).
   - Ensure that the file is added to all relevant targets.

### Notes
- If you encounter any issues with Firebase, ensure the `GoogleService-Info.plist` file is correctly added and linked to the project.
