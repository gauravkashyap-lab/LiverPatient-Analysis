--                                       Liver patient analysis
--=========================================================================================================================================================================================
--=========================================================================================================================================================================================
CREATE TABLE liver_patient_dataset (
    Age INT,
    Gender VARCHAR(11),
    TB FLOAT,
    DB FLOAT,
    Alkphos INT,
    Sgpt INT,
    Sgot INT,
    TP FLOAT,
    ALB FLOAT,
    AG_Ratio FLOAT,
    Selector VARCHAR(21)
);

--=========================================================================================================================================================================================
--=========================================================================================================================================================================================
-- Basic Level(Understanding the Data)

-- Q1 How many total records(patients) are in the Dataset?
SELECT
    COUNT(*) as total_records
from
    liver_patient_dataset;

-- Q2 How many male vs female patients are there?
select
    gender,
    COUNT(gender) as total_count
from liver_patient_dataset
group by Gender;

-- Q3 what is the average age of patients?
SELECT
    AVG(age) average_age
from
    liver_patient_dataset;

-- Q4 What is the minimum and maximum age in the dataset?
select
    MIN(age) as minimum_age,
    MAX(age) as maximum_age
from
    liver_patient_dataset;

-- Q5 How many patients are diagnossed with liver disease vs not?
select
    top 5 *
from liver_patient_dataset
select
    Selector,
    COUNT(Selector) as total_count
from liver_patient_dataset
group by Selector;

--=========================================================================================================================================================================================
--=========================================================================================================================================================================================
-- InterMediate Level (Aggregation & Filtering)

-- Q6 What is the average total billirubin level for liver disease patients vs not-patients?
select
    selector,
    AVG(TB) as average_TB
from
    liver_patient_dataset
group by
    selector;

-- Q7 Which age group has the highest number of liver disease patients vs non-patients?
select
    case
        when age between 0
        and 20 then '0-20'
        when age between 21
        and 40 then '21-40'
        when age between 41
        and 60 then '41-60'
        else '60+'
    end as age_group,
    selector,
    COUNT(*) total_patients
from
    liver_patient_dataset
group by
    case
        when age between 0
        and 20 then '0-20'
        when age between 21
        and 40 then '21-40'
        when age between 41
        and 60 then '41-60'
        else '60+'
    end,
    Selector
order by
    total_patients desc;

-- Q8 what is the average enzyme level(SGPT/SGOT) by gender?
SELECT
    gender,
    AVG(sgpt) as average_sgpt,
    AVG(sgot) as average_sgot
from
    liver_patient_dataset
group by
    gender 
    
-- Q9 How many patients have abnormal albumin levels?
select
    COUNT(*) as abnormal_albumin_levels
from
    liver_patient_dataset
where
    ALB < 3.5
    OR ALB > 5.0;

-- Q10 Which top 5 patients have the highest alkaline phosphatase values?
select
    top 5 *
from
    liver_patient_dataset
order by
    Alkphos desc;

--=========================================================================================================================================================================================
--=========================================================================================================================================================================================
-- Advance Level (Insights and Pattern).

-- Q11 Is there a correlation between alcohol_related indicators and liver desease?
SELECT
    Selector,
    CASE
        WHEN (Sgot / NULLIF(Sgpt, 0)) > 2 THEN 'High (Alcohol-related)'
        WHEN (Sgot / NULLIF(Sgpt, 0)) BETWEEN 1
        AND 2 THEN 'Moderate'
        ELSE 'Low'
    END AS risk_category,
    COUNT(*) AS total_patients
FROM
    liver_patient_dataset
GROUP BY
    Selector,
    CASE
        WHEN (Sgot / NULLIF(Sgpt, 0)) > 2 THEN 'High (Alcohol-related)'
        WHEN (Sgot / NULLIF(Sgpt, 0)) BETWEEN 1
        AND 2 THEN 'Moderate'
        ELSE 'Low'
    END;

-- Q12 Compare protien levels between disease and non disease patients.
select
    selector,
    ROUND(AVG(tp), 2) as total_protien,
    ROUND(AVG(alb), 2) as total_albumin,
    ROUND(AVG(ag_ratio), 2) as total_ag_ratio
from
    liver_patient_dataset
group by
    Selector;

-- Q13 Identify patients who have high bilirubin but are not diagnosed with liver disease.
select
    *
from
    liver_patient_dataset
where
    tb > 5.0
    AND selector = 'No Liver Disease';

-- Q14 Which combination of features is most common in liver disease patients?
SELECT
    TOP 1 Gender,
    CASE
        WHEN Age BETWEEN 0
        AND 20 THEN '0-20'
        WHEN Age BETWEEN 21
        AND 40 THEN '21-40'
        WHEN Age BETWEEN 41
        AND 60 THEN '41-60'
        ELSE '60+'
    END AS age_group,
    CASE
        WHEN Sgpt > 40 THEN 'High SGPT'
        ELSE 'Normal SGPT'
    END AS sgpt_level,
    COUNT(*) AS total_patients
FROM
    liver_patient_dataset
WHERE
    Selector = 'Liver Disease'
GROUP BY
    Gender,
    CASE
        WHEN Age BETWEEN 0
        AND 20 THEN '0-20'
        WHEN Age BETWEEN 21
        AND 40 THEN '21-40'
        WHEN Age BETWEEN 41
        AND 60 THEN '41-60'
        ELSE '60+'
    END,
    CASE
        WHEN Sgpt > 40 THEN 'High SGPT'
        ELSE 'Normal SGPT'
    END
ORDER BY
    total_patients DESC;

-- Q15 Create a rule to predict liver disease and compare it with actual results.
SELECT
    COUNT(*) AS total,
    SUM(
        CASE
            WHEN Selector = CASE
                WHEN (
                    CASE
                        WHEN TB > 1.2 THEN 1
                        ELSE 0
                    END + CASE
                        WHEN Sgpt > 40 THEN 1
                        ELSE 0
                    END + CASE
                        WHEN ALB < 3.5 THEN 1
                        ELSE 0
                    END
                ) >= 2 THEN 'Liver Disease'
                ELSE 'No Liver Disease'
            END THEN 1
            ELSE 0
        END
    ) AS correct_predictions,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN Selector = CASE
                    WHEN (
                        CASE
                            WHEN TB > 1.2 THEN 1
                            ELSE 0
                        END + CASE
                            WHEN Sgpt > 40 THEN 1
                            ELSE 0
                        END + CASE
                            WHEN ALB < 3.5 THEN 1
                            ELSE 0
                        END
                    ) >= 2 THEN 'Liver Disease'
                    ELSE 'No Liver Disease'
                END THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS accuracy_percentage
FROM
    liver_patient_dataset;

--                                                                      THANK YOU
--=========================================================================================================================================================================================
--=========================================================================================================================================================================================