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


Resolving Package.resolved File Corruption or Incompatibility Issues
If you encounter the following error while running the project:

Package.resolved file is corrupted or malformed; fix or delete the file to continue.

Follow these steps to resolve the issue:

1. **Delete the following files**:
   - Delete the `Package.resolved` file from the project:
     ```
     rm 5520_group44_ios/5520_IOS_Group44.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
     ```
   - Delete the Swift Package Manager cache:
     ```
     rm -rf ~/Library/Caches/org.swift.swiftpm
     ```

2. **Reset Xcode Package Cache**:
   - Open Xcode
   - Select:
     ```
     File > Packages > Reset Package Caches
     ```

3. **Resolve Dependencies**:
   - In Xcode, select:
     ```
     File > Packages > Resolve Package Versions
     ```

4. **Clean Build Folder**:
   - In Xcode, select:
     ```
     Product > Clean Build Folder
     ```
     or use the shortcut `Shift + Command + K`

5. **Run the Project Again**:
   - Click the **Run** button to rebuild the project

---

### **Save and Submit README File**

1. After editing the `README.md` file, save it.
2. Commit and push your changes to your branch:
   ```bash
   git add README.md
   git commit -m "Add instructions for resolving Package.resolved compatibility issues"
   git push origin feature/your-branch
   ```
