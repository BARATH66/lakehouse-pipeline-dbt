-- Gold dimension: descriptive attributes of a customer (who they are, what they subscribe to).
select
    customer_id,
    gender,
    is_senior_citizen,
    has_partner,
    has_dependents,
    has_phone_service,
    multiple_lines,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies,
    is_paperless_billing
from {{ ref('stg_customers') }}
