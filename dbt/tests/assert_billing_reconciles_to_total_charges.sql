-- Fails if any customer's billed total differs from their TotalCharges by more than 1 cent.
-- Customers with a NULL total_charges (tenure 0) are excluded: there is nothing to compare.
select customer_id, total_charges, total_billed
from {{ ref('int_customer_activity') }}
where total_charges is not null
  and abs(total_billed - total_charges) > 0.01
