from typing import Any


def calculate_bmi_and_loading(weight_kg: float, height_m: float) -> tuple[float, str, float]:
    """Task 1: Calculate BMI, classify category, and assign loading % via nested if statements."""
    bmi: float = weight_kg / (height_m ** 2)
    category: str = ""
    loading_pct: float = 0.0

    # Nested if structure for BMI classification and loading assignment
    if bmi < 25.0:
        if bmi < 18.5:
            category = "Underweight"
            loading_pct = 0.05  # 5% loading
        else:
            category = "Normal"
            loading_pct = 0.00  # 0% loading
    else:
        if bmi < 30.0:
            category = "Overweight"
            loading_pct = 0.15  # 15% loading
        else:
            category = "Obese"
            loading_pct = 0.30  # 30% loading

    return bmi, category, loading_pct


def get_base_premium(age: int, term_years: int) -> float:
    """Task 2: Use match/case with guards (case x if ...) for base premium by age band and term."""
    base_premium: float = 0.0

    match (age, term_years):
        # Young adult band (18-30)
        case (a, t) if 18 <= a <= 30 and t <= 15:
            base_premium = 4000.0
        case (a, t) if 18 <= a <= 30 and t > 15:
            base_premium = 5200.0

        # Mid-career band (31-45)
        case (a, t) if 31 <= a <= 45 and t <= 15:
            base_premium = 6500.0
        case (a, t) if 31 <= a <= 45 and t > 15:
            base_premium = 8200.0

        # Senior working band (46-60)
        case (a, t) if 46 <= a <= 60 and t <= 15:
            base_premium = 10500.0
        case (a, t) if 46 <= a <= 60 and t > 15:
            base_premium = 13000.0

        # Ineligible age band (< 18 or > 60)
        case _:
            base_premium = -1.0

    return base_premium


def calculate_final_premium(
    base_premium: float,
    age: int,
    is_smoker: bool,
    bmi_loading_pct: float,
    term_years: int,
) -> tuple[float, str]:
    """Task 3: Combine arithmetic, comparison, and logical operators with documented precedence."""
    # Operator Precedence Documentation (Expression 1 - Smoker & Age Surcharge Rate):
    # 1. Comparison operators (`>=`) evaluate first: `age >= 40` -> bool.
    # 2. Logical `and` evaluates next (higher precedence than `or`): `is_smoker and age >= 40`.
    # 3. Ternary conditional (`... if ... else ...`) evaluates lowest, returning 0.35, 0.20, or 0.0.
    smoker_rate: float = 0.35 if is_smoker and age >= 40 else (0.20 if is_smoker else 0.0)

    # Operator Precedence Documentation (Expression 2 - Multi-Policy / Long-Term Discount):
    # 1. Comparison operators (`not`, `>=`, `<`) evaluate first: `not is_smoker` (unary `not` binds
    #    tighter than `and`/`or`), `term_years >= 20`, and `bmi_loading_pct < 0.10`.
    # 2. Logical `and` binds tighter than `or`, grouping `(term_years >= 20 and bmi_loading_pct < 0.10)`
    #    before combining with `not is_smoker`.
    qualifies_discount: bool = not is_smoker and (term_years >= 20 and bmi_loading_pct < 0.10)
    discount_rate: float = 0.08 if qualifies_discount else 0.0

    # Operator Precedence Documentation (Expression 3 - Final Arithmetic Calculation):
    # 1. Parentheses `(...)` force addition and subtraction of rates first: `(1.0 + bmi_loading_pct + smoker_rate - discount_rate)`.
    # 2. Multiplication `*` executes next: `base_premium * combined_factor`.
    final_premium: float = base_premium * (1.0 + bmi_loading_pct + smoker_rate - discount_rate)

    # Assign premium band using comparison & logical operators
    band: str = "Standard"
    if smoker_rate >= 0.35 or bmi_loading_pct >= 0.30:
        band = "High-Risk Tier"
    elif smoker_rate > 0.0 or bmi_loading_pct > 0.0:
        band = "Rated Tier"
    elif qualifies_discount:
        band = "Preferred Plus"

    return final_premium, band


def parse_applicant_record(raw: dict[str, Any]) -> dict[str, Any] | None:
    """Task 5: Safely convert raw string/mixed inputs and catch ValueError/TypeError edge cases."""
    app_id: str = str(raw.get("id", "UNKNOWN")).strip()
    name: str = str(raw.get("name", "")).strip()

    try:
        age_str: str = str(raw["age"]).strip()
        weight_str: str = str(raw["weight_kg"]).strip()
        height_str: str = str(raw["height_m"]).strip()
        term_str: str = str(raw["term_years"]).strip()
        smoker_str: str = str(raw["smoker"]).strip().lower()

        if not age_str or not weight_str or not height_str or not term_str or not smoker_str:
            raise ValueError("Empty string provided for mandatory numeric/boolean field")

        age: int = int(age_str)
        weight_kg: float = float(weight_str)
        height_m: float = float(height_str)
        term_years: int = int(term_str)

        if height_m <= 0 or weight_kg <= 0 or term_years <= 0:
            raise ValueError("Height, weight, and policy term must be positive numbers")

        if smoker_str in {"yes", "true", "1", "y"}:
            is_smoker: bool = True
        elif smoker_str in {"no", "false", "0", "n"}:
            is_smoker = False
        else:
            raise ValueError(f"Invalid smoker flag '{smoker_str}'")

        return {
            "id": app_id,
            "name": name,
            "age": age,
            "weight_kg": weight_kg,
            "height_m": height_m,
            "term_years": term_years,
            "is_smoker": is_smoker,
        }

    except ValueError as err:
        print(f"[CONVERSION ERROR] Skipping {app_id} ({name}): {err}")
        return None


def process_batch_validation(applicants: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Task 4: Process 8 applicants with for-break-else in batch-validation mode."""
    evaluated_rows: list[dict[str, Any]] = []

    for raw_record in applicants:
        parsed: dict[str, Any] | None = parse_applicant_record(raw_record)
        if parsed is None:
            print(f"[BATCH HALTED] Ineligible/corrupt record encountered at {raw_record.get('id')}.")
            break

        bmi, bmi_cat, bmi_load = calculate_bmi_and_loading(parsed["weight_kg"], parsed["height_m"])
        base_prem: float = get_base_premium(parsed["age"], parsed["term_years"])

        # Check eligibility (age out of 18-60 range or extreme BMI > 45)
        if base_prem < 0 or bmi > 45.0:
            reason: str = "Age outside 18-60 range" if base_prem < 0 else f"Extreme BMI ({bmi:.1f})"
            print(f"[BATCH HALTED] Ineligible applicant {parsed['id']} ({parsed['name']}): {reason}.")
            break

        final_prem, band = calculate_final_premium(
            base_premium=base_prem,
            age=parsed["age"],
            is_smoker=parsed["is_smoker"],
            bmi_loading_pct=bmi_load,
            term_years=parsed["term_years"],
        )

        evaluated_rows.append({
            "id": parsed["id"],
            "name": parsed["name"],
            "age": parsed["age"],
            "bmi": bmi,
            "bmi_cat": bmi_cat,
            "smoker": "Yes" if parsed["is_smoker"] else "No",
            "term": parsed["term_years"],
            "base": base_prem,
            "band": band,
            "final": final_prem,
        })
    else:
        print(f"[BATCH VALIDATED] All {len(applicants)} applicants passed eligibility checks successfully.")

    return evaluated_rows


def print_summary_table(rows: list[dict[str, Any]]) -> None:
    border: str = "=" * 102
    divider: str = "-" * 102
    print(f"\n{border}")
    print(
        f"{'ID':<6} {'Name':<14} {'Age':>4} {'BMI':>6} {'BMI Class':<12} "
        f"{'Smoker':<7} {'Term':>5} {'Base (INR)':>11} {'Premium Band':<15} {'Final (INR)':>12}"
    )
    print(f"{divider}")

    for r in rows:
        print(
            f"{r['id']:<6} {r['name']:<14} {r['age']:>4} {r['bmi']:>6.1f} {r['bmi_cat']:<12} "
            f"{r['smoker']:<7} {r['term']:>4}y {r['base']:>11.2f} {r['band']:<15} {r['final']:>12.2f}"
        )

    print(f"{border}\n")


def main() -> None:
    # Run 1: 8 Valid Applicants -> triggers loop-else
    valid_eight: list[dict[str, Any]] = [
        {"id": "INS01", "name": "Aarav Sharma", "age": "26", "weight_kg": "68", "height_m": "1.75", "term_years": "20", "smoker": "no"},
        {"id": "INS02", "name": "Neha Gupta", "age": "24", "weight_kg": "48", "height_m": "1.65", "term_years": "10", "smoker": "no"},
        {"id": "INS03", "name": "Rohan Mehta", "age": "35", "weight_kg": "86", "height_m": "1.76", "term_years": "15", "smoker": "yes"},
        {"id": "INS04", "name": "Kavita Iyer", "age": "42", "weight_kg": "95", "height_m": "1.68", "term_years": "20", "smoker": "yes"},
        {"id": "INS05", "name": "Vikram Sethi", "age": "50", "weight_kg": "74", "height_m": "1.72", "term_years": "12", "smoker": "no"},
        {"id": "INS06", "name": "Pooja Verma", "age": "38", "weight_kg": "62", "height_m": "1.64", "term_years": "25", "smoker": "no"},
        {"id": "INS07", "name": "Arjun Nair", "age": "29", "weight_kg": "82", "height_m": "1.78", "term_years": "15", "smoker": "yes"},
        {"id": "INS08", "name": "Sunita Rao", "age": "55", "weight_kg": "79", "height_m": "1.60", "term_years": "18", "smoker": "no"},
    ]

    print(f"--- BATCH RUN 1: 8 Valid Applicants (Triggers loop-else) ---")
    rows_1: list[dict[str, Any]] = process_batch_validation(valid_eight)
    print_summary_table(rows_1)

    # Run 2: Batch containing conversion errors & ineligible applicant -> triggers break
    mixed_batch: list[dict[str, Any]] = [
        valid_eight[0],
        {"id": "INS09", "name": "Bad Age Text", "age": "thirty", "weight_kg": "70", "height_m": "1.75", "term_years": "15", "smoker": "no"},
        {"id": "INS10", "name": "Empty Input", "age": "", "weight_kg": "70", "height_m": "1.75", "term_years": "15", "smoker": "no"},
        {"id": "INS11", "name": "Underage", "age": "16", "weight_kg": "60", "height_m": "1.70", "term_years": "10", "smoker": "no"},
    ]

    print(f"--- BATCH RUN 2: Type Conversion Error & Ineligible Record (Triggers break) ---")
    for bad_item in mixed_batch[1:]:
        process_batch_validation([bad_item])


if __name__ == "__main__":
    main()