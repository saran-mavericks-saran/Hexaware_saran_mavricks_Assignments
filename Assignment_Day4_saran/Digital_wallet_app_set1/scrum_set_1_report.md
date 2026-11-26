# Day 4 – Doing Scrum – Sprint Simulation
**Set 1: Digital Wallet Application – Mid-Sprint Change**

---

## 1. Executive Summary & Sprint Planning

* **Business Context:** A fintech engineering team of five developers is executing a 10-day sprint to build core features for a digital wallet application.
* **Historical Velocity & Commitment:** Based on the previous three sprints (21, 24, and 23 story points), the team's average velocity is calculated as:
  $$\text{Average Velocity} = \frac{21 + 24 + 23}{3} = \frac{68}{3} = 22.67 \text{ story points}$$
  Accordingly, the team commits to **23 story points** for the current sprint.
* **Sprint Goal:** Deliver core peer-to-peer wallet transfers, bank top-ups, and real-time transaction notifications so users can fund their wallets and send money securely with zero critical defects by Day 10.
* **Selected Scope Overview:** Four user stories (`DW-101` through `DW-104`) were initially selected from the Product Backlog to match the 23-point capacity, covering bank account linking/top-ups (8 points), P2P transfers (8 points), filterable transaction history (5 points), and push notification toggles (2 points). *(Refer to Sheet 1: Sprint Backlog for full story details).*

---

## 2. Task Execution & Day 3 Daily Stand-up

During Sprint Planning, the primary stories were decomposed into technical sub-tasks (UI design, REST API development, ledger logic, and QA verification) with granular hour estimates to track daily progress on the Sprint Board. *(Refer to Sheet 2: Task Breakdown & Sprint Board).*

### Day 3 Daily Stand-up Summary
* **Developer 1 (Backend):**
  * *Yesterday:* Completed the database schema for the wallet ledger and began work on the `/wallet/topup` endpoint (`T-101B`).
  * *Today:* Finalizing the payment gateway webhook handler and writing unit tests for top-up transactions.
  * *Impediments:* None.
* **Developer 2 (Backend):**
  * *Yesterday:* Built the phone-number lookup service required for peer-to-peer transfers.
  * *Today:* Implementing the atomic debit/credit transfer service (`T-102B`).
  * *Impediments:* Blocked on missing sandbox credentials for the SMS OTP/PIN verification service needed to start `T-102C`.
* **Developer 3 (Frontend):**
  * *Yesterday:* Completed the "Add Money" UI screen (`T-101A`) and submitted Pull Request #14.
  * *Today:* Integrating the frontend top-up flow with the staging API and preparing to start the transaction history UI (`T-103A`).
  * *Impediments:* Waiting on peer review for PR #14 before merging to `main`.

---

## 3. Mid-Sprint Scope Change Management (Day 4)

On Day 4 of the sprint, business stakeholders introduced an urgent request for a **Refund-to-Wallet** feature (`DW-105`: *"As a user, I can receive merchant refunds directly into my digital wallet"*), which the development team estimated at **5 story points**.

* **Decision Authority & Governance:**
  * The **Product Owner** holds sole authority over Product Backlog ordering and determines whether the business value of the new refund feature outweighs planned, unstarted work.
  * The **Developers** evaluate technical feasibility, provide the 5-point effort estimate, and ensure the team's sustainable pace is protected.
* **Scope Trade-Off Execution:**
  * **Added:** `DW-105` (Refund-to-Wallet – 5 points) was brought into the active Sprint Backlog due to its high commercial urgency for merchant onboarding.
  * **Removed:** `DW-103` (Filterable Transaction History – 5 points) was removed from the sprint and returned to the top of the Product Backlog for Sprint 2. Because no tasks under `DW-103` had been started by Day 4, swapping equal-sized stories maintained the **23-point capacity** ($23 - 5 + 5 = 23$) and protected the core **Sprint Goal**.

---

## 4. Impediment Resolution & Burndown Trend Analysis

* **Active Impediment Resolution:**
  * **External Sandbox Access (`IMP-01`):** Raised on Day 3 when missing SMS OTP sandbox credentials threatened `T-102C`. The Scrum Master escalated the request to Platform Security and enabled a local mock OTP token so development remained unblocked until live keys arrived on Day 4.
  * **Mid-Sprint Scope Churn (`IMP-02`):** Raised on Day 4 following the Refund-to-Wallet request. Resolved immediately through a zero-sum scope swap facilitated between the Product Owner and Developers.
* **Burndown Trend Interpretation:** *(Refer to Sheet 3: Burndown Data and the downloaded Burndown Chart)*
  * The sprint burn follows a **stair-step trajectory** rather than a linear decline. After burning 2 points on Day 2 (`DW-104`), remaining work plateaued at 21 points across Days 2–4 while two large 8-point stories (`DW-101` and `DW-102`) progressed simultaneously and the Day 4 scope swap took place.
  * Once foundational backend APIs stabilized on Day 5, delivery accelerated sharply—closing 8 points on Day 5 (`DW-101`), 8 points on Day 7 (`DW-102`), and the final 5 points on Day 9 (`DW-105`). The team met its **Definition of Done** across all 23 points one full day ahead of the Day 10 deadline.

---

## 5. Sprint Retrospective & Action Plan

During the Sprint Retrospective, the team evaluated its workflow, collaboration, and bottlenecks:

* **What Went Well:**
  * Disciplined scope management on Day 4 allowed the team to accommodate a high-priority business request without overcommitting or compromising code quality.
  * Cross-functional pairing between backend and frontend engineers enabled rapid integration and testing of the replacement `DW-105` story.
* **What to Improve:**
  * Third-party sandbox credentials (`IMP-01`) were requested mid-sprint rather than validated prior to Sprint Planning.
  * Pull requests waited over 12 hours for peer reviews during Days 2 and 3, slowing down frontend integration.
* **Action Items:**
  1. **Enforce Dependency Checks in Definition of Ready (DoR):** Require verification of all external API keys, webhooks, and sandbox environments at least 48 hours before Sprint Planning. *(Owner: Scrum Master — Target: Next Backlog Refinement)*
  2. **Adopt a 4-Hour Pull Request Review SLA:** Configure automated Slack notifications for new PRs and reserve a dedicated 30-minute review block immediately following each Daily Stand-up. *(Owner: Tech Lead — Target: Sprint 2, Day 1)*

---

## 6. Definition of Done (DoD) Mapped to CI/CD Pipeline

To ensure every sprint increment is potentially releasable, the team enforces its **Definition of Done (DoD)** through four automated quality gates in the CI/CD pipeline:

1. **Build Stage (Compilation & Code Hygiene):**
   * *DoD Requirement:* Source code compiles cleanly with zero syntax errors, dependencies resolve deterministically, and formatting rules are followed.
   * *Pipeline Enforcement:* Pushing code to a feature branch triggers a containerized build that executes static code linters (`flake8`/`ESLint`), validates dependency lockfiles, and packages the build artifact. Any build or lint failure immediately halts progression.
2. **Test Stage (Automated Verification & Security):**
   * *DoD Requirement:* All unit and integration tests pass, automated test coverage reaches at least **80%**, and zero critical or high-severity vulnerabilities exist.
   * *Pipeline Enforcement:* The CI runner executes the automated test suite (`pytest`) against an ephemeral test database, enforces the 80% coverage threshold, and runs Static Application Security Testing (SAST) and dependency vulnerability scans before approving the build.
3. **Review Stage (Peer & Acceptance Validation):**
   * *DoD Requirement:* Code is peer-reviewed for maintainability and edge cases, and all user story Acceptance Criteria are verified in a staging preview.
   * *Pipeline Enforcement:* Branch protection policies prevent merging until at least **one peer developer approves** the Pull Request, all Build and Test status checks pass, and QA/Product Owner sign-off is logged on the preview environment.
4. **Merge Stage (Integration & Staging Deployment):**
   * *DoD Requirement:* Changes are cleanly integrated into `main`, API documentation is updated, and the staging environment passes post-deployment health checks.
   * *Pipeline Enforcement:* Upon approval, the pipeline squashes and merges the branch into `main`, runs automated post-merge smoke tests, deploys the updated container to staging, and automatically transitions the linked board ticket to **Done**.