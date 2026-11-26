from typing import Any


# ==============================================================================
# TASK 2 & 3: EVALUATION FUNCTION (6 Rules, Nested if-elif, match/case)
# ==============================================================================
def evaluate_applicant(applicant: dict[str, Any]) -> dict[str, Any]:
    # TASK 1: Explicit type hints on all local variables
    app_id: str = applicant["id"]
    name: str = applicant["name"]
    age: int = applicant["age"]
    income: float = applicant["income"]
    employment_type: str = applicant["employment_type"]
    existing_emi: float = applicant["existing_emi"]
    proposed_emi: float = applicant["proposed_emi"]
    credit_score: int = applicant["credit_score"]
    existing_loans: int = applicant["existing_loans"]

    status: str = "REJECTED"
    reason: str = "Eligible"
    credit_band: str = "N/A"
    interest_rate: float = 0.0
    loan_product: str = "Not Eligible"
    emi_ratio: float = 0.0

    # TASK 5: Edge-Case Validation (negative age, zero income, score out of 300-850 range)
    if age <= 0 or income <= 0 or credit_score < 300 or credit_score > 850:
        return {
            "id": app_id,
            "name": name,
            "credit_band": credit_band,
            "loan_product": loan_product,
            "interest_rate": interest_rate,
            "status": "INVALID",
            "reason": "Edge case: Invalid age, income, or credit score",
        }

    # TASK 2 - RULE 1: Age Band (21 to 60)
    if age < 21 or age > 60:
        reason = "Age outside 21-60 band"
    else:
        # TASK 2 - RULE 2 & RULE 4: Nested Employment Type & Income-to-EMI Ratio
        emi_ratio = (existing_emi + proposed_emi) / income
        if employment_type == "Salaried":
            if emi_ratio > 0.50:
                reason = "EMI ratio exceeds 50% limit (Salaried)"
        elif employment_type == "Self-Employed":
            if emi_ratio > 0.40:
                reason = "EMI ratio exceeds 40% limit (Self-Employed)"
        else:
            reason = "Unsupported employment type"

    # TASK 2 - RULE 3: Credit-Score Band (Fixed order: highest to lowest)
    if reason == "Eligible":
        if credit_score >= 750:
            credit_band = "Excellent"
        elif credit_score >= 680:
            credit_band = "Good"
        elif credit_score >= 600:
            credit_band = "Fair"
        else:
            credit_band = "Poor"
            reason = "Credit score below 600"

    # TASK 2 - RULE 5: Existing-Loan Limit (Max 3 active loans)
    if reason == "Eligible":
        if existing_loans > 3:
            reason = "Exceeds maximum 3 existing loans"

    # TASK 3: Use match/case to map credit-score band to rate and loan product
    if reason == "Eligible":
        match credit_band:
            case "Excellent":
                interest_rate = 8.5
                loan_product = "Prime Personal Loan"
            case "Good":
                interest_rate = 10.5
                loan_product = "Standard Personal Loan"
            case "Fair":
                interest_rate = 13.5
                loan_product = "Starter Secured Loan"
            case _:
                interest_rate = 0.0
                loan_product = "Not Eligible"
                reason = "Unmapped credit band"

    # TASK 2 - RULE 6: Final Decision
    if reason == "Eligible":
        status = "APPROVED"

    return {
        "id": app_id,
        "name": name,
        "credit_band": credit_band,
        "loan_product": loan_product,
        "interest_rate": interest_rate,
        "status": status,
        "reason": reason,
    }


# ==============================================================================
# TASK 4: LOOP OVER 10 APPLICANTS (continue, break, and loop-else)
# ==============================================================================
def process_applicants(applicants: list[dict[str, Any]], daily_limit: int) -> list[dict[str, Any]]:
    approved_count: int = 0
    results: list[dict[str, Any]] = []

    for person in applicants:
        decision: dict[str, Any] = evaluate_applicant(person)

        # TASK 4: Use 'continue' to skip invalid/edge-case records
        if decision["status"] == "INVALID":
            print(f"[SKIPPED] {person['id']} - {person['name']}: {decision['reason']}")
            continue

        results.append(decision)

        # TASK 4: Use 'break' when daily approval limit is reached
        if decision["status"] == "APPROVED":
            approved_count += 1
            if approved_count >= daily_limit:
                print(f"[LIMIT REACHED] Daily approval cap of {daily_limit} hit at {person['id']}.")
                break
    else:
        # TASK 4: loop-else runs ONLY if all 10 records finish without hitting 'break'
        print(f"[COMPLETED] Processed all {len(applicants)} records without hitting daily limit of {daily_limit}.")

    return results


# ==============================================================================
# TASK 5 & TASK 1: DRIVER & DECISION TABLE (100% f-strings)
# ==============================================================================
def print_decision_table(results: list[dict[str, Any]]) -> None:
    line: str = "=" * 98
    dash: str = "-" * 98
    print(f"\n{line}")
    print(f"{'ID':<7} {'Name':<15} {'Credit Band':<13} {'Loan Product':<24} {'Rate':<8} {'Decision':<10} {'Reason'}")
    print(f"{dash}")

    for row in results:
        rate_display: str = f"{row['interest_rate']:.1f}%"
        print(
            f"{row['id']:<7} {row['name']:<15} {row['credit_band']:<13} "
            f"{row['loan_product']:<24} {rate_display:<8} {row['status']:<10} {row['reason']}"
        )

    print(f"{line}\n")


def main() -> None:
    # 9 Pre-built test records covering rules & edge cases
    applicants: list[dict[str, Any]] = [
        {"id": "APP01", "name": "Arun Kumar", "age": 32, "income": 85000.0, "employment_type": "Salaried", "existing_emi": 10000.0, "proposed_emi": 15000.0, "credit_score": 780, "existing_loans": 1},
        {"id": "APP02", "name": "Priya Nair", "age": 19, "income": 50000.0, "employment_type": "Salaried", "existing_emi": 0.0, "proposed_emi": 10000.0, "credit_score": 720, "existing_loans": 0},
        {"id": "APP03", "name": "Vikram Rao", "age": -4, "income": 60000.0, "employment_type": "Salaried", "existing_emi": 5000.0, "proposed_emi": 10000.0, "credit_score": 700, "existing_loans": 1},
        {"id": "APP04", "name": "Meera Das", "age": 40, "income": 100000.0, "employment_type": "Self-Employed", "existing_emi": 20000.0, "proposed_emi": 15000.0, "credit_score": 710, "existing_loans": 2},
        {"id": "APP05", "name": "Karthik S", "age": 29, "income": 0.0, "employment_type": "Salaried", "existing_emi": 0.0, "proposed_emi": 12000.0, "credit_score": 740, "existing_loans": 0},
        {"id": "APP06", "name": "Sneha Roy", "age": 35, "income": 60000.0, "employment_type": "Salaried", "existing_emi": 20000.0, "proposed_emi": 15000.0, "credit_score": 760, "existing_loans": 1},
        {"id": "APP07", "name": "Rahul Verma", "age": 45, "income": 90000.0, "employment_type": "Salaried", "existing_emi": 10000.0, "proposed_emi": 12000.0, "credit_score": 550, "existing_loans": 1},
        {"id": "APP08", "name": "Divya Menon", "age": 38, "income": 110000.0, "employment_type": "Salaried", "existing_emi": 15000.0, "proposed_emi": 15000.0, "credit_score": 730, "existing_loans": 4},
        {"id": "APP09", "name": "Suresh Babu", "age": 28, "income": 70000.0, "employment_type": "Salaried", "existing_emi": 5000.0, "proposed_emi": 10000.0, "credit_score": 920, "existing_loans": 0},
    ]

    # YOUR INTERACTIVE INPUTS (Collected as the 10th applicant)
    print(f"--- Enter Details for Applicant 10 ---")
    name: str = input("What is your name: ").strip()
    age: int = int(input("What is your age: "))
    income: float = float(input("What is your income: "))
    employment_type: str = input("What is your employment type (Salaried/Self-Employed): ").strip().title()
    existing_emi: float = float(input("What is your Existing EMI: "))
    proposed_emi: float = float(input("What is your Proposed EMI: "))
    credit_score: int = int(input("What is your Credit Score: "))
    existing_loans: int = int(input("What is your Existing Loans count: "))

    # Append your interactive applicant to make 10 total records
    applicants.append({
        "id": "APP10",
        "name": name,
        "age": age,
        "income": income,
        "employment_type": employment_type,
        "existing_emi": existing_emi,
        "proposed_emi": proposed_emi,
        "credit_score": credit_score,
        "existing_loans": existing_loans,
    })

    # Run the batch processor and print the final decision table
    daily_approval_limit: int = 3
    final_decisions: list[dict[str, Any]] = process_applicants(applicants, daily_approval_limit)
    print_decision_table(final_decisions)


if __name__ == "__main__":
    main()