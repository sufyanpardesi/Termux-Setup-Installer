# Complete Automatic Procedure — Termux Setup Installer | Step One

## Installation Command (Copy & Paste)

Follow these simple steps:

1. Open the Termux app on your Android device.
2. Copy the installation command below.
3. Paste the command into Termux.
4. Press Enter to start the installer.

### One-Command Installation

    curl -fsSL https://raw.githubusercontent.com/sufyanpardesi/Termux-Setup-Installer/main/sufiyanpardesi | bash

**Important:** Run this command inside the Termux app.

## Requirements

- Android device with Termux installed.
- Active internet connection.
- Git (the launcher will try to install it if missing).

## Project Repository

https://github.com/sufyanpardesi/Termux-Setup-Installer

---

Created by **SUFIYAN PARDESI**

## Step Two — Start OpenCode After Installation

After the Termux Setup Installer has completed successfully:

1. Open Termux.
2. Type the following command:

```bash
opencode
```

3. Press Enter to launch OpenCode.

**Note:** OpenCode must be installed successfully before running this command.

---

# Complete Project Documentation

## 1. About This Project

**SUFIYAN PARDESI — Termux Setup Installer** is a Termux-based setup and configuration project designed to provide a safer, organized, and customizable starting environment for Android users.

The project includes a branded terminal interface, banner selection, theme selection, optional Security PIN protection, startup locking, software detection, installation preflight checks, logging, backup utilities, and privacy safeguards.

The installer-managed directory is:

`$HOME/Sufiyan-Pardesi/`

The project is designed to preserve existing user data and avoid moving personal projects.

## 2. Installation Launcher

The public launcher is named `sufiyanpardesi`.

It provides a one-command installation entry point:

```bash
curl -fsSL https://raw.githubusercontent.com/sufyanpardesi/Termux-Setup-Installer/main/sufiyanpardesi | bash
```

The launcher:

- Checks whether it is running inside Termux.
- Installs Git if it is missing.
- Checks for unsafe symbolic links.
- Creates the installer-managed directory.
- Clones the repository if it is not already installed.
- Updates an existing valid installer repository using a fast-forward-only Git pull.
- Stops if unexpected local installer changes are detected.
- Checks that the bootstrap script exists before starting it.

## 3. Terminal Banner System

The banner system supports:

- Default SUFIYAN PARDESI branding.
- Custom display-name selection.
- A CREATOR subtitle.
- Terminal-native text and ANSI colors.
- Centered banner alignment based on terminal width.
- A layout that adjusts to the available terminal columns.

The default banner uses a gold/yellow appearance with cyan accents.

**Important:** The current banner is terminal text, not an image. No banner image is required or displayed.

## 4. Available Themes

The theme selection module currently provides four choices:

1. **Cosmic Gold** — Default theme with gold, cyan, and purple accents.
2. **Ocean Blue** — Blue and cyan color palette.
3. **Royal Purple** — Purple, pink, and violet color palette.
4. **Emerald Green** — Green and gold color palette.

The selected theme name and color values can be saved in the installer's settings.

The theme selection and saving system is included. Full application-wide theme integration may require further development.

## 5. Security PIN Protection

The installer includes an optional Security PIN system.

Available choices:

- Enable Security PIN.
- Continue without a PIN (default).

When enabled:

- The user creates a PIN containing 4 to 12 digits.
- PIN entry is hidden while typing.
- The PIN is stored as a salted SHA-512 password hash using OpenSSL.
- The original PIN is not stored as plain text.
- PIN settings are saved with restricted file permissions.
- The startup lock can verify the PIN when a new interactive Termux shell starts.

The startup lock displays the SUFIYAN PARDESI banner before requesting the PIN.

The normal shell session continues after successful verification.

When PIN protection is disabled, no new startup lock hook is installed.

Existing PIN settings and existing startup hooks are checked and preserved rather than blindly overwritten.

## 6. Startup Lock System

The startup-lock module provides:

- Interactive shell detection.
- Security PIN verification during shell startup.
- Hidden PIN input.
- PIN verification using the stored salted hash.
- A branded terminal lock screen.
- Support for the installer's saved display name.
- Integration through the Termux `.bashrc` startup file when PIN protection is enabled.

The startup hook is intended to run only in interactive Bash sessions.

## 7. Software Detection

The detection module checks for the availability of:

- OpenCode
- Java
- Gradle
- Node.js
- NPM
- Git
- Android Debug Bridge (ADB)
- Android SDK Manager

It also checks Android SDK directories and selected build tools.

The current SDK detection path is:

`$HOME/android-sdk`

The detection module can display available software paths and version information where supported.

## 8. Installation Preflight and Compatibility Checks

Before any future large software installation phase, the current preflight module checks:

- Device architecture.
- Available storage.
- Existing OpenCode availability.
- Java and Gradle availability.
- Android SDK directories.
- Android Build Tools 35.0.0.
- Tools such as AAPT, AAPT2, ZIPALIGN, and APKSIGNER.

The preflight checks available storage and reports low storage when less than 2 GB is available.

It also identifies missing or incomplete components.

**Current limitation:** The preflight module performs checks and reports installation decisions. It does not download or install OpenCode, Android SDK, Gradle, Java, or Node.js.

## 9. OpenCode

OpenCode is included in the project's software detection and setup plan.

The README provides the following command for launching OpenCode after it has been installed:

```bash
opencode
```

The command works only when OpenCode is successfully installed and available in the Termux PATH.

**Current version status:**

- OpenCode detection: Included.
- OpenCode launch instructions: Included.
- Dedicated managed OpenCode directory: Created by the directory setup module.
- Automatic OpenCode download and installation: Not implemented in the current published setup phase.
- Automatic OpenCode upgrades: Not implemented in the current published setup phase.

## 10. Android Development Tools

The project layout reserves locations for Android development tools:

- Android SDK
- Android Platform Tools
- Android Build Tools
- Android SDK Command-line Tools
- AAPT and AAPT2
- ZIPALIGN
- APKSIGNER
- Java
- Gradle

The current version can detect several existing tools and inspect selected SDK components.

**Important:** These development tools are not automatically downloaded or installed by the current published setup phase. Their installation and compatibility handling are planned for a later development phase.

## 11. Base Termux Packages

The bootstrap script checks for the following required commands and attempts to install missing packages through the Termux package manager:

| Required command | Termux package |
|---|---|
| curl | curl |
| git | git |
| openssl | openssl |
| tar | tar |
| sha256sum | coreutils |
| find | findutils |

Git is also checked by the public launcher before the repository is cloned.

The initial one-line installation command requires `curl` to be available so Termux can download the launcher.

## 12. Managed Directory Structure

The installer-managed directory is:

`$HOME/Sufiyan-Pardesi/`

Its planned and managed structure includes:

- `Installer/` — Repository and installer source files.
- `OpenCode/` — Reserved for installer-managed OpenCode data.
- `Android-SDK/` — Reserved for managed Android SDK files.
- `Gradle/` — Reserved for managed Gradle files.
- `Packages/` — Package-related metadata.
- `Themes/` — Installer-managed theme resources.
- `Settings/` — User profile, theme, and PIN settings.
- `Modules/` — Runtime installer modules.
- `Config/` — Installer configuration.
- `Updates/` — Update-related files.
- `Backups/` — Installer-managed backup archives.
- `Logs/` — Installer logs.
- `Installation-Details/` — Installation information.
- `Tests/` — Test-related files.

These directories are for installer-managed data only.

Existing personal folders and projects must remain in their original locations.

## 13. Safety and Data Protection

The safety module includes:

- Installation path validation.
- Symbolic-link checks.
- Protection against unsafe paths.
- Managed-directory validation.
- Preservation of existing user data.
- No automatic deletion of user projects.
- No automatic relocation of personal folders.
- Checks before using existing settings files.

The installer configuration explicitly disables automatic deletion and project relocation.

Existing private application configurations must not be overwritten.

## 14. Backup System

The backup module provides utilities to:

- Create compressed TAR.GZ archives for approved managed directories.
- Exclude selected sensitive files and private directories.
- Restrict backup file permissions.
- Verify archive integrity.
- Generate SHA-256 checksums.
- List available installer backup archives.

Approved backup targets include selected managed directories such as OpenCode, Android-SDK, Gradle, Themes, Modules, Config, and Updates.

**Current limitation:** Backup functions are included as a module, but the current main setup flow does not automatically run a backup operation.

## 15. Privacy Protection

The privacy module includes checks for:

- Protected directories.
- Paths outside the user's HOME directory.
- Symbolic links.
- Sensitive filenames.
- Private configuration directories.
- Credentials, tokens, PIN settings, and log files.

Private settings, credentials, logs, and backups must not be uploaded to the public GitHub repository.

GitHub upload checks identify files that require an additional content review. They do not replace a complete manual content audit.

## 16. Logging System

The logging module provides:

- Timestamped log entries.
- INFO, SUCCESS, WARNING, and ERROR message levels.
- Restricted log-file permissions.
- Unique log filenames.
- Basic redaction of common passwords, PINs, API keys, tokens, and bearer credentials.

Logs are stored under the installer-managed Logs directory.

## 17. Typewriter Animation Module

A reusable terminal text animation module is included.

It supports:

- Character-by-character text output.
- Animated lines.
- Animated prompts.
- Configurable typing speed.
- Enable and disable functions.

**Current limitation:** The animation module is included, but it is not yet connected to every prompt and message in the main installer flow.

## 18. Local Testing

The repository includes an isolated local test script.

It checks:

- PIN-disabled setup.
- PIN-enabled setup.
- Profile settings.
- Theme settings.
- PIN configuration.
- Startup-lock hook creation.
- Use of isolated test directories.

The test script is designed not to modify the user's real installation.

## 19. What the Current Version Installs

The current published setup phase can:

- Install missing required base Termux packages through `pkg`.
- Clone or update the installer repository.
- Create the installer's managed directory structure.
- Configure a default or custom banner name.
- Save a selected theme.
- Configure optional Security PIN protection.
- Install the startup-lock hook when PIN protection is enabled.
- Initialize the logging system.
- Detect existing software and Android SDK components.
- Run installation preflight checks.

## 20. What the Current Version Does Not Install

The current published setup phase does not automatically install or upgrade:

- OpenCode.
- Android SDK.
- Android Platform Tools.
- Android Build Tools.
- Java.
- Gradle.
- Node.js.
- NPM.
- Additional Android development environments.

These components are part of the software detection and future installation plan, but their automatic download and installation workflows are not yet implemented in this version.

No large software downloads are performed by the current preflight module.

## 21. Important Project Principles

- Preserve existing user data.
- Do not move personal projects.
- Do not overwrite private configurations.
- Do not expose PINs, passwords, tokens, or credentials.
- Do not automatically delete user files.
- Reuse compatible existing software where future installation logic supports it.
- Check compatibility before installing development tools.
- Do not report an installation as successful unless it has been verified.
- Keep private runtime data outside the public GitHub repository.

## 22. Project Status

**Current Release Stage: Initial Setup, Configuration, Detection, and Preflight**

The repository currently provides the initial setup foundation and supporting modules.

The automated installation of OpenCode and Android development tools is a planned next phase and is not included in the current published installation workflow.

---

## Project Creator

**SUFIYAN PARDESI**

GitHub: https://github.com/sufyanpardesi

Repository: https://github.com/sufyanpardesi/Termux-Setup-Installer
