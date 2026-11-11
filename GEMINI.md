# PayVault Autonomous Sprint Rules & Protocols

When the user instructs "run daily sprint" or requests the next engineering milestone, execute the mandatory 6-phase autonomous engineering protocol without deviation:

### 6-Phase Daily Sprint Protocol

1. **Phase 1: Task Selection & Alignment**
   - Read `docs/AUTONOMOUS_BACKLOG.md`.
   - Identify the earliest unchecked sprint (`- [ ] **Sprint X: ...**`).
   - Log the sprint name and scope to the terminal and context.

2. **Phase 2: Architectural Design & Implementation**
   - Follow strict Feature-First Clean Architecture + MVVM structure.
   - Maintain zero hardcoded colors; resolve dynamically via `Theme.of(context).colorScheme`.
   - Ensure every `FloatingActionButton` defines an explicit, unique `heroTag`.
   - Keep landscape viewport safe (800x360dp) with zero RenderFlex overflow.
   - NEVER use emojis in code, UI text, logs, or commit messages.

3. **Phase 3: Automated Test Engineering**
   - Write unit and widget tests covering all newly added logic and state mutations.
   - Verify that test assertions strictly pass without flaky timings.

4. **Phase 4: Sprint Gatekeeper Verification**
   - Execute: `dart run tool/sprint_gate.dart`.
   - Must pass all 4 phases:
     1. `flutter pub get`
     2. `dart format --output=none --set-exit-if-changed lib test`
     3. `flutter analyze --no-pub` (0 errors, 0 warnings)
     4. `flutter test --no-pub` (All unit and widget tests pass)

5. **Phase 5: Backlog Updating & Conventional Commit**
   - Mark the completed sprint in `docs/AUTONOMOUS_BACKLOG.md` as `- [x] **Sprint X: ...**`.
   - Stage changes: `git add .`.
   - Commit with clean conventional commit message format (no emojis), e.g.:
     `feat(sprint-X): implement <feature-name> with clean architecture and automated tests`

6. **Phase 6: Remote Push & Sync Verification**
   - Push to remote: `git push origin main`.
   - Verify push success: execute `git log origin/main..HEAD` and confirm the output is completely empty.
