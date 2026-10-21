select * from {{ ref('stg_billing') }} where amount <= 0
