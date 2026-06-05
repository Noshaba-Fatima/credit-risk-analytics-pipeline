-- USE YOUR DATABASE (Make sure this matches the name of your database in Workbench)
USE credit_risk_db;

-- ==============================================================================
-- QUERY 1: OVERALL PORTFOLIO HEALTH (THE DEFAULT RATE)
-- Business Question: What percentage of our total customer base is defaulting?
-- ==============================================================================
SELECT 
    default_status, 
    COUNT(*) AS total_customers,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM credit_risk_portfolio)) * 100, 2) AS percentage_of_portfolio
FROM credit_risk_portfolio
GROUP BY default_status;



-- ==============================================================================
-- QUERY 2: RISK SEGMENTATION BY EDUCATION
-- Business Question: Which education demographic carries the highest credit risk?
-- ==============================================================================
SELECT 
    education, 
    COUNT(*) AS customer_count,
    SUM(default_status) AS total_defaults,
    ROUND((SUM(default_status) / COUNT(*)) * 100, 2) AS default_rate_percentage
FROM credit_risk_portfolio
GROUP BY education
ORDER BY default_rate_percentage DESC;


-- ==============================================================================
-- QUERY 3: HIGH UTILIZATION RISK ANALYSIS (USING A CTE)
-- Business Question: Do customers who use most of their credit limit default more?
-- ==============================================================================
WITH UtilizationData AS (
    SELECT 
        limit_bal,
        bill_amt1,
        default_status,
        -- Calculate how much of their limit they used in the most recent month
        CASE 
            WHEN limit_bal > 0 THEN ROUND((bill_amt1 / limit_bal) * 100, 2)
            ELSE 0 
        END AS utilization_percentage
    FROM credit_risk_portfolio
)
SELECT 
    CASE 
        WHEN utilization_percentage >= 90 THEN '1. Maxed Out (90-100%+)'
        WHEN utilization_percentage >= 50 THEN '2. High Utilization (50-89%)'
        ELSE '3. Healthy Utilization (<50%)'
    END AS credit_usage_tier,
    COUNT(*) AS total_customers,
    ROUND((SUM(default_status) / COUNT(*)) * 100, 2) AS default_rate_percentage
FROM UtilizationData
GROUP BY credit_usage_tier
ORDER BY credit_usage_tier;

-- ==============================================================================
-- QUERY 4: AGE DEMOGRAPHICS RISK SEGMENTATION
-- Business Question: Which age brackets present the highest financial risk?
-- ==============================================================================
SELECT 
    CASE 
        WHEN age < 25 THEN 'Under 25 (Entry Level)'
        WHEN age BETWEEN 25 AND 34 THEN '25-34 (Young Professional)'
        WHEN age BETWEEN 35 AND 44 THEN '35-44 (Mid-Career)'
        WHEN age BETWEEN 45 AND 54 THEN '45-54 (Established)'
        ELSE '55+ (Senior/Retirement)'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(default_status) AS total_defaults,
    ROUND((SUM(default_status) / COUNT(*)) * 100, 2) AS default_rate_percentage,
    ROUND(AVG(limit_bal), 2) AS avg_credit_limit
FROM credit_risk_portfolio
GROUP BY age_group
ORDER BY age_group;

-- ==============================================================================
-- QUERY 5: HISTORICAL DEBT UTILIZATION PROFILE
-- Business Question: What is the long-term credit usage behavior of our customers?
-- ==============================================================================
WITH HistoricalUtilization AS (
    SELECT 
        limit_bal,
        default_status,
        -- Calculate the average statement balance across all 6 months
        ((bill_amt1 + bill_amt2 + bill_amt3 + bill_amt4 + bill_amt5 + bill_amt6) / 6) AS avg_historical_bill
    FROM credit_risk_portfolio
)
SELECT 
    CASE 
        WHEN limit_bal = 0 THEN 'No Credit Limit'
        WHEN (avg_historical_bill / limit_bal) * 100 >= 75 THEN 'Critical Utilization (>75%)'
        WHEN (avg_historical_bill / limit_bal) * 100 BETWEEN 30 AND 74.99 THEN 'Moderate Utilization (30-75%)'
        ELSE 'Low Utilization (<30%)'
    END AS historical_usage_profile,
    COUNT(*) AS total_customers,
    SUM(default_status) AS total_defaults,
    ROUND((SUM(default_status) / COUNT(*)) * 100, 2) AS default_rate_percentage
FROM HistoricalUtilization
GROUP BY historical_usage_profile
ORDER BY default_rate_percentage DESC;

-- ==============================================================================
-- QUERY 6: RECENT REPAYMENT DELAY ANALYSIS
-- Business Question: How accurately does a 1-2 month payment delay predict ultimate default?
-- ==============================================================================
SELECT 
    CASE 
        WHEN pay_0 <= 0 THEN 'Account Current / Paid In Full'
        WHEN pay_0 = 1 THEN '1 Month Overdue'
        WHEN pay_0 = 2 THEN '2 Months Overdue'
        ELSE '3+ Months Severe Delinquency'
    END AS repayment_status_tier,
    COUNT(*) AS total_customers,
    SUM(default_status) AS total_defaults,
    ROUND((SUM(default_status) / COUNT(*)) * 100, 2) AS default_rate_percentage
FROM credit_risk_portfolio
GROUP BY repayment_status_tier
ORDER BY default_rate_percentage DESC;

-- ==============================================================================
-- QUERY 7: DEBT TRAJECTORY & MOMENTUM
-- Business Question: Are customers with growing balances more likely to default?
-- ==============================================================================
WITH BalanceMomentum AS (
    SELECT 
        limit_bal,
        bill_amt1 AS current_balance,
        bill_amt6 AS oldest_balance,
        default_status,
        -- Calculate the raw dollar change in their balance over 6 months
        (bill_amt1 - bill_amt6) AS balance_growth
    FROM credit_risk_portfolio
)
SELECT 
    CASE 
        WHEN balance_growth > 50000 THEN '1. Surging Debt (+$50k)'
        WHEN balance_growth BETWEEN 10000 AND 50000 THEN '2. Growing Debt (+$10k to $50k)'
        WHEN balance_growth BETWEEN -10000 AND 9999 THEN '3. Stable Balance'
        ELSE '4. Paying Down Debt (-$10k+)'
    END AS debt_trajectory,
    COUNT(*) AS total_customers,
    SUM(default_status) AS total_defaults,
    ROUND((SUM(default_status) / COUNT(*)) * 100, 2) AS default_rate_percentage
FROM BalanceMomentum
GROUP BY debt_trajectory
ORDER BY debt_trajectory;

-- ==============================================================================
-- QUERY 8: REPAYMENT RATIO (THE MINIMUM PAYMENT TRAP)
-- Business Question: What happens to risk when customers only pay a fraction of their bill?
-- ==============================================================================
WITH RepaymentRatios AS (
    SELECT 
        bill_amt2,
        pay_amt1,
        default_status,
        CASE 
            -- Avoid division by zero for people with no bills
            WHEN bill_amt2 > 0 THEN ROUND((pay_amt1 / bill_amt2) * 100, 2)
            ELSE 100 
        END AS percent_of_bill_paid
    FROM credit_risk_portfolio
)
SELECT 
    CASE 
        WHEN percent_of_bill_paid >= 100 THEN 'Paid in Full'
        WHEN percent_of_bill_paid BETWEEN 50 AND 99.99 THEN 'Paid Majority (>50%)'
        WHEN percent_of_bill_paid BETWEEN 10 AND 49.99 THEN 'Paid Partial (10-50%)'
        ELSE 'Minimum/Missing Payment (<10%)'
    END AS repayment_behavior,
    COUNT(*) AS total_customers,
    ROUND((SUM(default_status) / COUNT(*)) * 100, 2) AS default_rate_percentage
FROM RepaymentRatios
-- Filter out negative bills or refunds to keep the analysis clean
WHERE bill_amt2 > 0 
GROUP BY repayment_behavior
ORDER BY default_rate_percentage DESC;

-- ==============================================================================
-- QUERY 9: PORTFOLIO RISK EXPOSURE BY CREDIT LIMIT QUARTILE
-- Business Question: Is the bank exposed to higher default rates on large credit lines?
-- ==============================================================================
WITH LimitQuartiles AS (
    SELECT 
        limit_bal,
        default_status,
        -- Break the 30,000 customers into 4 equal tiers based on their credit limit
        NTILE(4) OVER (ORDER BY limit_bal DESC) AS credit_tier
    FROM credit_risk_portfolio
)
SELECT 
    CASE 
        WHEN credit_tier = 1 THEN 'Tier 1 (Highest Credit Limits)'
        WHEN credit_tier = 2 THEN 'Tier 2 (High-Mid Limits)'
        WHEN credit_tier = 3 THEN 'Tier 3 (Low-Mid Limits)'
        ELSE 'Tier 4 (Lowest Credit Limits)'
    END AS portfolio_tier,
    MIN(limit_bal) AS tier_minimum_limit,
    MAX(limit_bal) AS tier_maximum_limit,
    COUNT(*) AS total_customers,
    ROUND((SUM(default_status) / COUNT(*)) * 100, 2) AS default_rate_percentage
FROM LimitQuartiles
GROUP BY portfolio_tier, credit_tier
ORDER BY credit_tier;