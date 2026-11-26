# Day 4 – Doing Scrum – Sprint Simulation

**Set 3: E-Learning Platform – Scope Change Handling**

## 1. Sprint Plan & Sprint Goal

* **Business Context:** An e-learning platform engineering team is executing a 10-day sprint to deliver core student learning features ahead of an upcoming product launch.
* **Velocity & Commitment:** Based on the team's established velocity of **30 story points**, five prioritized user stories (`EL-301` through `EL-305`) were committed for the sprint. *(Refer to your exported Sprint Backlog sheet for full story and point breakdowns).*
* **Sprint Goal:** Deliver the core student learning experience—adaptive video playback controls, timed module quizzes, and real-time course progress tracking—with full automated test coverage so learners can complete and track course modules smoothly before launch.

## 2. Change-Impact Note (Day 6 Scope Change Request)

On **Day 6** of the 10-day sprint, the Product Owner requested adding a **"Certificate Download"** feature (`EL-306`: *"As a learner, I can generate and download a verified PDF completion certificate upon finishing a course"*) for the upcoming launch.

* **Effort & Feasibility Assessment:**
  * The Developers estimated the full **Certificate Download** feature (custom PDF template rendering, unique verification ID, and completion validation) at **8 story points**, or a minimal MVP version (basic static PDF download upon 100% completion) at **5 story points**.
  * With only **4 working days remaining** (Days 7–10), absorbing extra work without removing unstarted scope would overload the team and threaten release quality.
* **What Can Be Swapped Out vs. What Must Wait:**
  * **What Can Be Swapped Out (Zero-Sum MVP Swap):** If a basic certificate download is strictly required for launch, the team can bring in the **5-point MVP version of `EL-306`** *only* by swapping out unstarted, non-critical scope of equal size—specifically removing **`EL-305` (Discussion Reply Notifications – 4 points)** and deferring minor UI polish on **`EL-304`**.
  * **What Must Wait (Deferred to Next Sprint):** Advanced certificate capabilities (custom branding, QR verification portal, and LinkedIn share integration—the remaining **3 points** of the full 8-point scope) **must wait** until Sprint 2. If `EL-305` has already entered active development on Day 6, the entire `EL-306` story is placed at the top of the Product Backlog for the next sprint rather than disrupting mid-flight work.
* **How the Sprint Goal Is Protected:**
  * Core Sprint Goal stories (**`EL-301` Video Playback**, **`EL-302` Timed Quizzes**, and **`EL-303` Progress Tracking**) remain locked and protected from interruption.
  * The Scrum Master facilitates a strict zero-sum trade-off with the Product Owner so total sprint commitment never exceeds **30 story points**, preventing burnout, context-switching, and technical debt.

## 3. Blocked Developer Stand-up & Scrum Master Follow-up

### Daily Stand-up Statement (Frontend Developer)
* **Yesterday:** Built the UI layout and countdown timer component for `EL-302` (Timed Module Quiz Engine).
* **Today:** Wiring the quiz submission flow to the scoring endpoint and writing component unit tests.
* **Impediments:** **Blocked** — The backend API contract (request/response JSON schema and HTTP status codes) for `POST /api/v1/quizzes/{id}/submit` is missing, preventing frontend integration.

### Scrum Master Follow-up Action
1. **Immediate Alignment Huddle:** Immediately following the 15-minute Daily Stand-up, the Scrum Master schedules a focused **15-minute technical alignment call** between the Frontend Developer, Backend Lead, and QA Engineer.
2. **Contract Freeze & Mocking:** The developers co-author and merge the OpenAPI/Swagger JSON contract into the repository within 1 hour. This allows the Frontend Developer to immediately generate a mock API server and continue integration testing without waiting for backend implementation to finish.

## 4. Velocity Calculation & Partial Work Rule

*(Refer to your exported Completed Points sheet for the end-of-sprint story status table).*

* **Final Sprint Velocity Calculation:**
  * Completed 100% (`EL-301`: 8 pts, `EL-302`: 8 pts, `EL-303`: 5 pts, `EL-305`: 4 pts) = **25 story points**.
  * Partially completed (`EL-304` – Lesson Bookmarking & Notes, **80% done** at Day 10) = **0 story points**.
  * **Total Earned Velocity:** **25 story points** ($8 + 8 + 5 + 0 + 4 = 25$).

* **How Partially Done Work Is Counted in Scrum:**
  * In Scrum, velocity measures **fully "Done" increments** that satisfy the team's Definition of Done—never partial effort.
  * Because **`EL-304` (5 points)** is only **80% complete** when the sprint ends, it receives **0 points** in the current sprint. Awarding partial credit (such as 4 points) would distort capacity forecasting and inflate velocity without delivering shippable software.
  * Instead, `EL-304` returns to the Product Backlog, the remaining 20% of work (QA verification and bug fixes) is re-estimated (e.g., at **1 or 2 points**) during Backlog Refinement, and full points are counted in the sprint where the story is completely finished.

## 5. Sprint Retrospective (Start–Stop–Continue) & SMART Action Items

### Start–Stop–Continue Summary
* **Start:**
  * Finalizing and publishing OpenAPI/JSON API contracts during Backlog Refinement before Sprint Planning begins.
  * Splitting 5- and 8-point stories into smaller vertical slices so stories reach QA earlier in the sprint.
* **Stop:**
  * Accepting mid-sprint scope additions (such as the Day 6 certificate request) without an explicit, same-day story swap from the Product Owner.
  * Waiting until Day 9 to begin end-to-end QA verification on medium-sized stories (`EL-304`).
* **Continue:**
  * Running automated linting and unit test checks on every Pull Request to keep `main` builds healthy.
  * Using immediate post-stand-up 15-minute technical huddles to clear developer blockers rapidly.

### Three SMART Action Items

1. **Publish API Contracts Prior to Sprint Planning:**
   * *Action:* Backend and Frontend leads will document and merge OpenAPI JSON schemas for **100% of API-dependent stories** into the repository at least **24 hours before Sprint Planning** so zero stories are blocked on missing contracts during the upcoming 10-day sprint. *(Owner: Tech Lead)*
2. **Enforce a Strict Zero-Sum Scope Change Policy:**
   * *Action:* Whenever a mid-sprint feature request is raised by stakeholders, the Product Owner and Scrum Master will conduct a formal impact review within **4 business hours** and remove an equal or greater number of unstarted story points before adding any new task to the Sprint Board, keeping sprint commitment capped at **100% of planned capacity** throughout Sprint 2. *(Owner: Product Owner & Scrum Master)*
3. **Eliminate Carryover Work via Mid-Sprint QA Checkpoints:**
   * *Action:* Developers will move at least **50% of committed stories** to the "In QA" column by **Day 5 of the sprint** so QA has sufficient runway to verify all stories against the Definition of Done, reducing incomplete carryover stories from 1 (`EL-304`) to **0** by the end of Sprint 2. *(Owner: QA Lead & Development Team)*

## 6. How Automation Supports the Definition of Done (DoD)

Automated engineering practices transform the **Definition of Done** from a subjective manual checklist into an objective, enforceable quality gate before any increment is merged or released:

* **Linting (Code Quality & Maintainability):** Static code analyzers (such as `flake8`, `black`, or `ESLint`) run automatically on every commit to detect syntax errors, unused variables, and formatting inconsistencies, ensuring a clean, uniform codebase across all developers.
* **Unit Tests (Functional Reliability & Regression Prevention):** Automated unit test suites (`pytest`, `Jest`) validate core business logic and edge cases (such as quiz auto-submission timers and course progress calculations) in seconds, guaranteeing that new changes do not break existing functionality.
* **CI/CD Pipeline (Automated Gatekeeping):** The continuous integration pipeline automatically executes linting, unit tests, code-coverage thresholds, and security scans on every Pull Request—blocking merges if any check fails so every increment remains potentially releasable at the end of the sprint.