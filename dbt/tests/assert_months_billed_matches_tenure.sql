-- Fails if the number of billing rows differs from tenure_months for customers that have billing.
-- Customers with a NULL total_charges (tenure 0) have no billing rows and are excluded.
select customer_id, tenure_months, months_billed
from {{ ref('int_customer_activity') }}
where total_charges is not null
  and months_billed <> tenure_months
