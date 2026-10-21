-- Fails if gold lost or gained customers compared with silver.
select 'fct_customer_churn' as model, g.n as gold_rows, s.n as silver_rows
from (select count(*) n from {{ ref('fct_customer_churn') }}) g,
     (select count(*) n from {{ ref('stg_customers') }}) s
where g.n <> s.n
union all
select 'dim_customer', g.n, s.n
from (select count(*) n from {{ ref('dim_customer') }}) g,
     (select count(*) n from {{ ref('stg_customers') }}) s
where g.n <> s.n
