# Churn BI: Four-Tier BI Framework on gold (Power BI)

Personal project. Data: Telco customer churn (Kaggle, public), built through bronze, silver and gold in SQL Server (`lakehouse_lab`). Billing history is synthetic and labeled. Theme: **black** (`StaticResources\RegisteredResources\churnBlack.json`).

## Design: one page, four buttons

A single page, `Churn Analytics`. Four buttons across the top switch the content below them:

| Button | Tier | Shows |
|---|---|---|
| Descriptive: What happened | Descriptive | 5 KPI cards, churn rate by contract, customers by tenure band |
| Diagnostic: Why it happened | Diagnostic | Churn rate by payment method and internet service, gap to overall by contract, segment table |
| Predictive: What is likely | Predictive | Placeholder until the churn model scores customers |
| Prescriptive: What to do | Prescriptive | Placeholder until the scores table exists |

Switching uses **bookmarks**: each bookmark hides the other tiers' visuals. Bookmarks are created in Desktop (steps below), then assigned to the buttons.

## Model
Star schema, Import mode, Windows authentication, parameters `ServerName` and `DatabaseName`.
`FactCustomerChurn` (gold.fct_customer_churn, 7,043 rows) to `DimCustomer` (gold.dim_customer, 7,043 rows), one relationship on `customer_id`. 13 measures in the Descriptive and Diagnostic display folders. No date table: the only dates are invented, so trends use tenure bands.

## Create the four bookmarks (in Power BI Desktop)
1. Open `powerbi\churn_bi.pbip`. Sign in to SQL Server with Windows authentication if asked. Click **Refresh**.
2. **View > Selection pane** and **View > Bookmarks pane**.
3. The tier visuals overlap each other, so group them first: select all visuals of one tier (the Selection pane shows type and title), then Ctrl+G. Rename the groups `Descriptive`, `Diagnostic`, `Predictive`, `Prescriptive`. Keep the four buttons outside any group.
4. Show only the Descriptive group (eye icons in the Selection pane). In the Bookmarks pane click **Add**, rename it `Descriptive`. In the bookmark's **...** menu turn **Data off** so slicer and filter state is not stored.
5. Repeat for the other three tiers, one bookmark each.
6. Select a button, open **Format > Action**, set **Type = Bookmark**, and pick the matching bookmark. Do this for all four buttons.
7. Save, then Ctrl+click a button in Reading view to test.

## Honest limits
- Predictive and prescriptive tiers are placeholders until a churn model and a `gold.fct_churn_scores` table exist.
- Monthly revenue trends are not shown: billing dates are synthetic.
- Not opened in Desktop yet by me. The semantic model passes an offline TMDL check; the report JSON has not been checked by Desktop.
- Not tested in the Power BI service.
