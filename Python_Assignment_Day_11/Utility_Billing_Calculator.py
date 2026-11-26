from typing import Any


def calculate_energy_charge(units: float) -> float:
    """Task 1: Progressive 4-slab calculation using if-elif logic."""
    charge: float = 0.0

    if units <= 100:
        charge = units * 3.50
    elif units <= 200:
        charge = (100 * 3.50) + ((units - 100) * 5.00)
    elif units <= 400:
        charge = (100 * 3.50) + (100 * 5.00) + ((units - 200) * 7.50)
    else:
        charge = (100 * 3.50) + (100 * 5.00) + (200 * 7.50) + ((units - 400) * 9.00)

    return charge


def get_fixed_charge(category: str) -> float:
    """Task 2: Map consumer category to fixed charge using match/case."""
    fixed_charge: float = 0.0

    match category.strip().lower():
        case "domestic":
            fixed_charge = 50.00
        case "commercial":
            fixed_charge = 150.00
        case "industrial":
            fixed_charge = 350.00
        case _:
            fixed_charge = -1.0

    return fixed_charge


def calculate_final_bill(
    units: float,
    category: str,
    is_late: bool,
    is_online: bool,
) -> dict[str, Any]:
    """Task 3: Combine charges, surcharge, and rebate with deliberate operator precedence."""
    energy_charge: float = calculate_energy_charge(units)
    fixed_charge: float = get_fixed_charge(category)
    base_bill: float = energy_charge + fixed_charge

    # Deliberate Operator Precedence Explanation:
    # In Python, multiplication (*) and division (/) bind tighter than addition (+) and subtraction (-).
    # Below, `base_bill * 0.05` and `base_bill * 0.02` are evaluated BEFORE adding or subtracting from `base_bill`,
    # even without outer parentheses around the multiplication terms. Parentheses around the ternary
    # expressions `(base_bill * 0.05 if is_late else 0.0)` ensure conditional checks evaluate cleanly
    # before the `+` and `-` operators combine them into `net_bill`.
    surcharge: float = base_bill * 0.05 if is_late else 0.0
    rebate: float = base_bill * 0.02 if is_online else 0.0
    net_bill: float = base_bill + (base_bill * 0.05 if is_late else 0.0) - (base_bill * 0.02 if is_online else 0.0)

    return {
        "units": units,
        "category": category.strip().title(),
        "energy_charge": energy_charge,
        "fixed_charge": fixed_charge,
        "surcharge": surcharge,
        "rebate": rebate,
        "net_bill": net_bill,
    }


def print_single_bill(bill: dict[str, Any]) -> None:
    """Task 5: Formatted single bill output using f-strings, alignment, and 2 decimals."""
    border: str = "=" * 56
    divider: str = "-" * 56
    print(f"\n{border}")
    print(f"{'ELECTRICITY BILL SUMMARY':^56}")
    print(f"{divider}")
    print(f"{'Consumer Category':<30}: {bill['category']:>22}")
    print(f"{'Units Consumed (kWh)':<30}: {bill['units']:>22.2f}")
    print(f"{'Energy Slab Charge (INR)':<30}: {bill['energy_charge']:>22.2f}")
    print(f"{'Category Fixed Charge (INR)':<30}: {bill['fixed_charge']:>22.2f}")
    print(f"{'Late Payment Surcharge (5%)':<30}: {bill['surcharge']:>+22.2f}")
    print(f"{'Online Payment Rebate (2%)':<30}: {-bill['rebate']:>+22.2f}")
    print(f"{divider}")
    print(f"{'NET PAYABLE AMOUNT (INR)':<30}: {bill['net_bill']:>22.2f}")
    print(f"{border}\n")


def generate_annual_statement(
    monthly_units: list[float],
    category: str,
    late_months: set[int],
    online_months: set[int],
) -> None:
    """Task 4 (Part A): Use a for loop to produce a 12-month consumption statement."""
    months: list[str] = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ]
    border: str = "=" * 86
    divider: str = "-" * 86

    print(f"\n{border}")
    print(f"{f'12-MONTH CONSUMPTION & BILLING STATEMENT ({category.title()})':^86}")
    print(f"{divider}")
    print(
        f"{'Month':<7} {'Units':>10} {'Energy':>12} {'Fixed':>10} "
        f"{'Surcharge':>12} {'Rebate':>10} {'Net Bill':>14}"
    )
    print(f"{divider}")

    total_units: float = 0.0
    total_payable: float = 0.0

    for idx, month_name in enumerate(months):
        units: float = monthly_units[idx]
        is_late: bool = (idx + 1) in late_months
        is_online: bool = (idx + 1) in online_months
        bill: dict[str, Any] = calculate_final_bill(units, category, is_late, is_online)

        total_units += units
        total_payable += bill["net_bill"]

        print(
            f"{month_name:<7} {bill['units']:>10.2f} {bill['energy_charge']:>12.2f} "
            f"{bill['fixed_charge']:>10.2f} {bill['surcharge']:>12.2f} "
            f"{bill['rebate']:>10.2f} {bill['net_bill']:>14.2f}"
        )

    print(f"{divider}")
    print(f"{'ANNUAL TOTAL':<7} {total_units:>10.2f} {'':>36} {total_payable:>26.2f}")
    print(f"{border}\n")


def run_interactive_meter_loop() -> None:
    """Task 4 (Part B) & Task 5: Accept readings with a while loop until 'q' and handle invalid inputs."""
    print(f"--- Interactive Meter Reading Calculator (Enter 'q' to quit) ---")

    while True:
        raw_units: str = input("Enter units consumed (kWh) or 'q' to quit: ").strip()
        if raw_units.lower() == "q":
            print(f"Exiting interactive billing session.")
            break

        # Validate numeric reading and reject negative consumption
        try:
            units: float = float(raw_units)
            if units < 0:
                print(f"[ERROR] Invalid reading: Units cannot be negative ({units:.2f}). Try again.\n")
                continue
        except ValueError:
            print(f"[ERROR] Invalid input '{raw_units}': Please enter a numeric value or 'q'.\n")
            continue

        category: str = input("Enter category (domestic / commercial / industrial): ").strip()
        if get_fixed_charge(category) < 0:
            print(f"[ERROR] Invalid category '{category}'. Choose domestic, commercial, or industrial.\n")
            continue

        late_input: str = input("Is payment late? (y/n): ").strip().lower()
        online_input: str = input("Is payment made online? (y/n): ").strip().lower()

        if late_input not in {"y", "n"} or online_input not in {"y", "n"}:
            print(f"[ERROR] Please answer 'y' or 'n' for surcharge and rebate flags.\n")
            continue

        bill: dict[str, Any] = calculate_final_bill(
            units=units,
            category=category,
            is_late=(late_input == "y"),
            is_online=(online_input == "y"),
        )
        print_single_bill(bill)


def main() -> None:
    # 1. Produce 12-Month Consumption Statement using a for loop
    sample_year_units: list[float] = [
        95.0, 100.0, 101.0, 180.0, 200.0, 201.0,
        350.0, 400.0, 401.0, 250.0, 140.0, 110.0,
    ]
    generate_annual_statement(
        monthly_units=sample_year_units,
        category="domestic",
        late_months={4, 8},
        online_months={1, 2, 3, 5, 6, 7, 9, 10, 11, 12},
    )

    # 2. Run interactive while loop until 'q'
    run_interactive_meter_loop()


if __name__ == "__main__":
    main()