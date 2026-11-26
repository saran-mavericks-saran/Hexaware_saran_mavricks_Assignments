# Day 4 – Doing Scrum – Sprint Simulation

**Set 2: Airline Web Check-in – Blocked Dependency**

## 1. Team Capacity Calculation & Sprint Commitment

* **Business Context:** An airline's web check-in engineering team is executing an 8-day sprint to streamline passenger check-in and ancillary seat-upgrade flows when an external payment-gateway sandbox outage occurs mid-sprint.
* **Capacity Calculation:** Given 6 team members, 8 working days, and a 70% focus factor (accounting for Scrum ceremonies, code reviews, and operational overhead):

$$
\text{Net Person-Days} = 6 \text{ members} \times 8 \text{ days} \times 0.70 = 33.6 \text{ person-days}
$$

Assuming an 8-hour workday:

$$
\text{Total Available Hours} = 33.6 \text{ person-days} \times 8 \text{ hours/day} = 268.8 \text{ hours}
$$

* **Story Point Commitment:** Based on the team's historical rate of approximately 1 story point per person-day (~8 hours of effort), the team commits to **32 story points** (within a safe sustainable range of 30–34 points).

## 2. Sprint Plan, Sprint Goal & Definition of Ready (DoR)

### Sprint Goal
Enable passengers to complete mobile web check-in, select preferred legroom seats, and download Apple/Google Wallet boarding passes seamlessly with zero payment or session timeouts by Day 8.

### Selected Sprint Backlog & Definition of Ready (DoR) Verification (32 Points)

Every selected story passed the team's **Definition of Ready (DoR)** checklist (*clear user value, testable Acceptance Criteria, sized in story points, UI/UX mocks attached, and dependencies identified*) prior to Sprint Planning:

| Story ID | User Story | Story Points | DoR Verification Checklist |
| :--- | :--- | :---: | :--- |
| **WC-201** | As a passenger, I can retrieve my booking using my PNR and last name to initiate web check-in. | 5 | [x] Acceptance Criteria defined<br>[x] Sized & decomposed<br>[x] Reservation API contract verified |
| **WC-202** | As a passenger, I can view an interactive cabin seat map and select an extra-legroom upgrade. | 8 | [x] Figma UI mocks approved<br>[x] Seat-inventory API live<br>[x] Sized at 8 points |
| **WC-203** | As a passenger, I can pay for my seat upgrade via credit/debit card during check-in. | 8 | [x] Acceptance Criteria defined<br>[x] PCI-compliant payment flow reviewed<br>[x] Payment sandbox access noted |
| **WC-204** | As a passenger, I can generate and download a mobile boarding pass with a dynamic QR code. | 6 | [x] QR payload spec signed off<br>[x] Wallet pass templates attached<br>[x] Sized at 6 points |
| **WC-205** | As a passenger, I can add my frequent-flyer number during check-in to earn miles. | 5 | [x] Loyalty validation rules clear<br>[x] Edge cases documented<br>[x] Sized at 5 points |
| **Total** | | **32** | **All 5 stories meet 100% of DoR criteria** |

## 3. Impediment Log & Scrum Master Resolution Plan

Mid-sprint (Day 4), the third-party **payment-gateway sandbox** required for end-to-end testing of story `WC-203` (Seat Upgrade Payment) went offline due to unscheduled vendor maintenance.

### Impediment Log Entry

| Field | Details |
| :--- | :--- |
| **Impediment ID** | `IMP-204` |
| **Date Raised** | Sprint Day 4 (09:30 AM) |
| **Description** | External Payment-Gateway Sandbox API is returning HTTP `503 Service Unavailable`, blocking integration and QA verification for the seat-upgrade checkout flow (`WC-203`). |
| **Impact** | **High** — Blocks 8 story points (`WC-203`) and threatens full end-to-end completion of the paid seat-upgrade portion of the Sprint Goal. |
| **Owner** | Scrum Master |
| **Escalation Path** | Tier 1: Vendor Developer Support Portal (Ticket #PG-8841) $\rightarrow$ Tier 2: Airline Payment Integration Lead $\rightarrow$ Tier 3: Vendor Technical Account Manager & Airline Engineering Manager (if unresolved > 24 hours). |
| **Expected Resolution** | Vendor ETA is 36 hours (by Day 5 evening); local mock workaround operational within 4 hours. |

### How the Scrum Master Removes the Impediment
1. **Immediate Vendor Escalation:** Logs a P1 support ticket with the payment gateway provider and engages the Airline Payment Integration Lead to obtain an exact restoration ETA.
2. **Unblock Engineering via Mock Service:** Facilitates a 20-minute technical huddle between backend and QA engineers to spin up a lightweight **WireMock/stub payment endpoint** simulating approved, declined, and timeout responses so frontend/backend development and unit testing on `WC-203` continue without idle time.
3. **Re-sequence Sprint Work:** Coordinates with developers to swarm on unblocked stories (`WC-201`, `WC-204`, and `WC-205`) first, reserving final live-sandbox smoke testing of `WC-203` for Day 6 once vendor access returns.

## 4. Backlog Refinement Session (Next Sprint Preparation)

During the mid-sprint Backlog Refinement session, the Product Owner and Developers reviewed the top five candidate stories for Sprint 2 and split one oversized 13-point epic into smaller, independently deliverable vertical slices.

### Top 5 Candidate Stories for Next Sprint

| Story ID | User Story Title | Initial Estimate | Action Taken | Refined Estimate |
| :--- | :--- | :---: | :--- | :---: |
| **WC-301** | Multi-passenger international check-in with automated passport OCR & visa validation | **13 pts** | **Split** into two vertical slices (`WC-301A` and `WC-301B`) | — |
| $\hookrightarrow$ **WC-301A** | Multi-passenger domestic check-in for up to 6 travelers on a single PNR | — | Split Slice 1 (Core multi-pax flow) | **5 pts** |
| $\hookrightarrow$ **WC-301B** | International passport MRZ scan & destination visa compliance check | — | Split Slice 2 (Compliance & OCR) | **8 pts** |
| **WC-302** | Pre-purchase excess checked baggage allowance during web check-in | 5 pts | Clarified weight-tier rules; ready for sprint | **5 pts** |
| **WC-303** | Automated SMS & WhatsApp check-in reminder 24 hours before departure | 3 pts | Verified notification template; ready | **3 pts** |
| **WC-304** | Self-service flight rebooking for delayed connecting flights | 8 pts | Identified dependency on Flight Ops API; needs spike | **8 pts** |
| **WC-305** | Accessibility assistance request (wheelchair / special meal selection) | 3 pts | Added IATA SSR code mapping; ready | **3 pts** |

## 5. Sprint Review Agenda & Demonstration Script

### Sprint Review Agenda (60 Minutes)
* **00:00 – 05:00 | Welcome & Sprint Context (Scrum Master):** Review Sprint Goal, team capacity (32 points committed), and impact of the Day 4 payment sandbox outage (`IMP-204`).
* **05:00 – 15:00 | Product Increment Overview (Product Owner):** Summarize completed stories (`WC-201` through `WC-205`) and business value delivered.
* **15:00 – 40:00 | Live Product Demonstration (Developers):** Walk stakeholders through the working check-in increment against Acceptance Criteria.
* **40:00 – 50:00 | Stakeholder Feedback & Q&A (All):** Gather reactions from Airline Operations, Customer Experience, and Commercial leads.
* **50:00 – 60:00 | Product Backlog & Release Roadmap Update (Product Owner):** Review upcoming priorities (refined multi-passenger check-in and baggage stories) and adjust target release dates.

### Demonstration Script Mapped to Acceptance Criteria

| Demo Step | Story ID | Presenter Action | Expected Result & Acceptance Criteria Verified |
| :--- | :--- | :--- | :--- |
| **1. Booking Lookup** | `WC-201` | Enter valid 6-character PNR (`AX94K2`) and passenger last name (`Sharma`) on the web check-in landing page and click **Find Booking**. | **AC-1 & AC-2:** System retrieves itinerary within 2 seconds, displays flight details, and handles invalid PNR inputs with a clear error message. |
| **2. Seat Selection** | `WC-202` | Open the interactive aircraft seat map, filter for extra-legroom rows (Rows 12–14), and select Seat `12A` ($35 upgrade). | **AC-1 & AC-3:** Occupied seats appear disabled; `12A` highlights in green and updates the cart summary with the $35 fee. |
| **3. Upgrade Payment** | `WC-203` | Enter test card details in the checkout modal and submit payment (verified against restored payment sandbox). | **AC-1 & AC-2:** Payment authorizes cleanly, generates a transaction receipt ID, and locks Seat `12A` on the passenger manifest. |
| **4. Mobile Boarding Pass** | `WC-204` | Complete check-in and click **Add to Apple/Google Wallet** and **Download PDF**. | **AC-1 & AC-3:** Boarding pass renders with passenger name, gate, boarding group, Seat `12A`, and a scannable IATA BCBP QR code. |
| **5. Loyalty Accrual** | `WC-205` | Enter a valid 9-digit Frequent Flyer ID (`FF-772190441`) before finalizing check-in. | **AC-1:** System validates tier status ("Gold") and prints tier recognition on the generated boarding pass. |

## 6. Distributed Asynchronous Stand-up & Format Comparison

To accommodate team members working across **IST (Bengaluru, UTC+5:30)** and **EST (New York, UTC-5:00)**, the team conducts a structured written Daily Stand-up in a dedicated `#web-checkin-standup` Slack channel before the IST evening handoff.

### Written Asynchronous Stand-up Thread (Day 5)

> **Scrum Bot [09:00 AM IST / 11:30 PM EST]:** Daily Stand-up Thread — Sprint Day 5 | Goal: *Seamless web check-in & seat upgrades (32 pts)*. Please post updates by 06:30 PM IST / 09:00 AM EST!
>
> * **Ananya (Backend – IST) [05:45 PM IST / 08:15 AM EST]:**
>   * **Yesterday:** Completed PNR lookup endpoint (`WC-201`) and spun up the WireMock payment stub so `WC-203` dev wasn't stalled by `IMP-204`.
>   * **Today:** Integrated the real payment gateway SDK now that sandbox access is restored; running integration tests on `WC-203`.
>   * **Blockers / Handoff:** `@David (QA - EST)` — `WC-203` is deployed to `staging-eu`; ready for your card-decline edge-case tests during your morning.
> * **Rohan (Frontend – IST) [06:00 PM IST / 08:30 AM EST]:**
>   * **Yesterday:** Built the interactive cabin seat map component (`WC-202`) and wired up mobile responsiveness.
>   * **Today:** Connected the seat selection state to the checkout cart and resolved a Safari layout bug on the QR boarding pass (`WC-204`).
>   * **Blockers / Handoff:** `@Elena (Frontend - EST)` — Left PR #42 open for the boarding pass Wallet button; please review when you log on.
> * **David (QA – EST) [09:05 AM EST / 06:35 PM IST]:**
>   * **Yesterday:** Automated end-to-end Playwright tests for `WC-201` and `WC-205` (all 18 test cases green).
>   * **Today:** Picking up `@Ananya`'s handoff to run live payment sandbox regression tests on `WC-203`.
>   * **Blockers / Handoff:** None.
> * **Elena (Frontend – EST) [09:15 AM EST / 06:45 PM IST]:**
>   * **Yesterday:** Completed frequent-flyer validation UI (`WC-205`) and merged PR #39.
>   * **Today:** Reviewing `@Rohan`'s PR #42 first thing, then finalizing accessibility ARIA labels on the seat map.
>   * **Blockers / Handoff:** None.

### Comparison: Asynchronous vs. Live Synchronous Stand-up

| Dimension | Written Asynchronous Stand-up | Live Synchronous Stand-up |
| :--- | :--- | :--- |
| **Time Zone Flexibility** | High — Eliminates late-night or early-morning calls across IST and EST time zones. | Low — Requires finding an overlapping window (e.g., 07:30 PM IST / 10:00 AM EST), causing meeting fatigue. |
| **Documentation & Traceability** | Creates a searchable, timestamped audit trail of progress, PR links, and explicit handoffs. | Verbal updates are easily forgotten unless someone manually takes notes. |
| **Blocker Resolution Speed** | Slower — Clarifying questions or complex blockers may wait hours for the next time zone to come online. | Immediate — Team members can swarm and resolve misunderstandings in real time within seconds. |
| **Team Rapport & Engagement** | Lower — Transactional text updates reduce spontaneous collaboration and social connection. | Higher — Face-to-face tone and body language strengthen team cohesion and shared ownership. |