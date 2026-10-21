-- One row per customer: staging customer attributes plus a summary of their billing rows.
-- Left join on purpose: customers with no billing (tenure 0) are kept, with 0 months billed.
with billing as (
    select
        customer_id,
        count(*)                              as months_billed,
        sum(amount)                           as total_billed,
        min(bill_month)                       as first_bill_month,
        max(bill_month)                       as last_bill_month,
        cast(avg(amount) as decimal(10,2))    as avg_monthly_amount
    from {{ ref('stg_billing') }}
    group by customer_id
)

select
    c.customer_id,
    c.tenure_months,
    c.contract_type,
    c.internet_service,
    c.payment_method,
    c.monthly_charges,
    c.total_charges,
    c.is_churned,
    coalesce(b.months_billed, 0)    as months_billed,
    coalesce(b.total_billed, 0)     as total_billed,
    b.first_bill_month,
    b.last_bill_month,
    b.avg_monthly_amount
from {{ ref('stg_customers') }} c
left join billing b
    on b.customer_id = c.customer_id
