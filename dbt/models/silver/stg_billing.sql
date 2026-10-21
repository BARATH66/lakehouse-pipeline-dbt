select
    concat(customer_id, '-', right('00' + cast(billing_month_no as varchar(3)), 3)) as billing_id,
    customer_id,
    cast(billing_month_no as int)       as billing_month_no,
    cast(bill_month as date)            as bill_month,
    cast(amount as decimal(10,2))       as amount,
    _batch_id,
    _loaded_at
from {{ source('bronze', 'telco_billing') }}
