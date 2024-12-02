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


请按照以下步骤解决问题：

1. **删除以下文件**：
   - 删除项目中的 `Package.resolved` 文件：
     ```
     rm 5520_group44_ios/5520_IOS_Group44.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
     ```
   - 删除 Swift Package Manager 的缓存：
     ```
     rm -rf ~/Library/Caches/org.swift.swiftpm
     ```

2. **重置 Xcode 的包缓存**：
   - 打开 Xcode。
   - 依次选择：
     ```
     File > Packages > Reset Package Caches
     ```

3. **重新解析依赖**：
   - 在 Xcode 中选择：
     ```
     File > Packages > Resolve Package Versions
     ```

4. **清理构建文件夹**：
   - 在 Xcode 中选择：
     ```
     Product > Clean Build Folder
     ```
     或使用快捷键 `Shift + Command + K`。

5. **重新运行项目**：
   - 点击 **Run** 按钮重新构建项目。

---

### **保存并提交 README 文件**

1. 在编辑好 `README.md` 文件后，将其保存。
2. 提交更改并推送到你的分支：
   ```bash
   git add README.md
   git commit -m "Add instructions for resolving Package.resolved compatibility issues"
   git push origin feature/your-branch

