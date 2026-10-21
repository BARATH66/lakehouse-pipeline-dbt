-- Gold fact: one row per customer with churn status, value and segment columns.
-- ltv = total billed to date (derived from the synthetic billing table, which reconciles to TotalCharges).
select
    customer_id,
    contract_type,
    internet_service,
    payment_method,
    tenure_months,
    case
        when tenure_months <= 12 then '0-12 months'
        when tenure_months <= 24 then '13-24 months'
        when tenure_months <= 48 then '25-48 months'
        else '49-72 months'
    end                                  as tenure_band,
    monthly_charges,
    total_charges,
    months_billed,
    total_billed                         as ltv,
    is_churned,
    1 - is_churned                       as is_active
from {{ ref('int_customer_activity') }}
