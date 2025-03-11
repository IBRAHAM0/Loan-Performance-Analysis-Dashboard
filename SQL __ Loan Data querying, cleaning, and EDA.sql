-- Preparing the Database

-- Creating the "financial_loan" table

CREATE TABLE loan (
	    id  Int, 
    address_state  Text, 
    application_type  Text, 
    emp_length  Text, 
    emp_title  Text, 
    grade  Text, 
    home_ownership  Text, 
    issue_date  Text, 
    last_credit_pull_date  Date, 
    last_payment_date  Date, 
    loan_status  Text, 
    next_payment_date  Date, 
    member_id  Int, 
    purpose  Text, 
    sub_grade  Text, 
    term  Text, 
    verification_status  Text, 
    annual_income  Numeric, 
    dti  Numeric, 
    installment  Numeric, 
    int_rate  Numeric, 
    loan_amount  Int, 
    total_acc  Int, 
    total_payment  Int
);

	
-- Import records from the source into the "financial_loan" table

COPY loan
FROM 'D:\financial_loan.csv'
DELIMITER ','
CSV HEADER;

-- Overview the dataset
SELECT *
FROM loan;

--------------------------------------------<<<<<<<(( Data Cleaning ))>>>>>>>---------------------------------------------------------

-- 1. Check for duplicates 

SELECT *, COUNT(*) AS duplicates
FROM loan
GROUP BY id, address_state, application_type, emp_length, emp_title, grade, home_ownership, issue_date, last_credit_pull_date, 
		last_payment_date, loan_status, next_payment_date, member_id, purpose, sub_grade, term, verification_status, annual_income, 
		dti, installment, int_rate, loan_amount, total_acc, total_payment
HAVING COUNT(*)>1;


-- 2. Casting Columns to Appropriate Data Types


ALTER TABLE loan  					-- Casting the "issue_date" as a "Date" type.
ALTER COLUMN issue_date TYPE DATE
USING issue_date :: DATE;


-- Review the data

SELECT *
FROM loan;



--========================================================================================================================================
--------------------------------------------<<<<<<<(( EXPLORATORY DATA ANALYSIS 'EDA' ))>>>>>>>-------------------------------------------



-- A) KPIs & Calculations

									-- Total Loan Applications
SELECT COUNT(id) AS total_apps
FROM loan;

									-- MTD Loan Applications
SELECT COUNT(id) AS total_apps
FROM loan
WHERE EXTRACT(month FROM issue_date) = 12;


									-- PMTD Loan Applications
SELECT COUNT(id) AS total_apps
FROM loan
WHERE EXTRACT(month FROM issue_date) = 11;


			--------------------------------------------------------------------------


									-- Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount 
FROM loan;


									-- MTD Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount 
FROM loan
WHERE EXTRACT(month FROM issue_date) = 12;


									-- PMTD Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount 
FROM loan
WHERE EXTRACT(month FROM issue_date) = 11;


			--------------------------------------------------------------------------


									--  Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Receieved 
FROM loan;


									--  MTD Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Receieved 
FROM loan
WHERE EXTRACT(month FROM issue_date) = 12;


									--  PMTD Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Receieved 
FROM loan
WHERE EXTRACT(month FROM issue_date) = 11;


			--------------------------------------------------------------------------


									--  Average Interest Rate
SELECT ROUND(AVG(int_rate) * 100, 2) AS Average_Interest_Rate 
FROM loan;


									--  MTD Average Interest Rate
SELECT ROUND(AVG(int_rate) * 100, 2) AS MTD_Average_Interest_Rate 
FROM loan
WHERE EXTRACT(month FROM issue_date) = 12;


									--  PMTD Average Interest Rate
SELECT ROUND(AVG(int_rate) * 100, 2) AS PMTD_Average_Interest_Rate 
FROM loan
WHERE EXTRACT(month FROM issue_date) = 11;


			--------------------------------------------------------------------------


									--  Average Dept To Income (DTI) 
SELECT ROUND(AVG(dti) * 100, 2) AS Average_Interest_Rate 
FROM loan;


									--  MTD Average Dept To Income (DTI) 
SELECT ROUND(AVG(dti) * 100, 2) AS MTD_Average_Interest_Rate 
FROM loan
WHERE EXTRACT(month FROM issue_date) = 12;


									--  PMTD Average Dept To Income (DTI) 
SELECT ROUND(AVG(dti) * 100, 2) AS PMTD_Average_Interest_Rate 
FROM loan
WHERE EXTRACT(month FROM issue_date) = 11;



			--------------------------------------------------------------------------
			--------------------------------------------------------------------------

-- B) GOOD LOAN ISSUED


									--  Good Loan Percentage
SELECT ROUND(
	(COUNT(
		CASE 
			WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id
		END) * 100.0)
		/ COUNT(id) 
		, 2) AS Good_Loan_percentage
FROM loan;


									--  Good Loan Applications

SELECT COUNT(id) AS Good_Loan_Applications 
FROM loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';


									--  Good Loan Funded Amount
SELECT SUM(loan_amount) AS Good_Loan_Funded_Amount 
FROM loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';


									--  Good Loan Amount Received
SELECT SUM(total_payment) AS Good_Loan_Received_Amount 
FROM loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';



-- C) BAD LOAN ISSUED
									--  Bad Loan Percentage
SELECT ROUND(
		(COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0)
			/ COUNT(id)
					, 2) AS Bad_Loan_percentage
FROM loan;


									--  Bad Loan Applications
SELECT COUNT(id) AS Bad_Loan_Applications 
FROM loan
WHERE loan_status = 'Charged Off';


									--  Bad Loan Funded Amount
SELECT SUM(loan_amount) AS Bad_Loan_Funded_Amount 
FROM loan
WHERE loan_status = 'Charged Off';


									--  Bad Loan Amount Received
SELECT SUM(total_payment) AS Bad_Loan_Received_Amount 
FROM loan
WHERE loan_status = 'Charged Off';


			--------------------------------------------------------------------------
			--------------------------------------------------------------------------

-- D) LOAN Status

									--  LOAN Status in Totals
SELECT
	loan_status AS Loan_Status,
	COUNT(id) AS Total_Applications,
	SUM(total_payment) AS Total_Amount_Recieved,
	SUM(loan_amount) AS Total_Funded_Amount,
	ROUND(AVG(int_rate * 100),2) AS Interest_Rate,
	ROUND(AVG(dti * 100), 2) AS DTI 
FROM loan
GROUP BY loan_status;


									--  MTD LOAN Status 
SELECT
	loan_status AS Loan_Status,
	SUM(total_payment) AS MTD_Total_Amount_Recieved,
	SUM(loan_amount) AS MTD_Total_Funded_Amount
FROM loan
WHERE EXTRACT(MONTH FROM issue_date) = 12
GROUP BY loan_status;


			--------------------------------------------------------------------------
			--------------------------------------------------------------------------

-- E) MONTHLY TREND BY ISSUE DATE


SELECT
	EXTRACT(MONTH FROM issue_date) AS Month_Number,
	TO_CHAR(issue_date, 'Month') AS Month_Name,
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Received_Amount
FROM loan
GROUP BY 1, 2
ORDER BY 1;


			--------------------------------------------------------------------------
			--------------------------------------------------------------------------

-- F) REGIONAL ANALYSIS BY STATE

SELECT
	address_state AS State,
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Received_Amount
FROM loan
GROUP BY address_state
ORDER BY address_state;


			--------------------------------------------------------------------------
			--------------------------------------------------------------------------


-- G) LOAN TERM ANALYSIS

SELECT
	term AS Term,
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Received_Amount
FROM loan
GROUP BY term
ORDER BY term;


			--------------------------------------------------------------------------
			--------------------------------------------------------------------------

-- H) EMPLOYEE LENGTH ANALYSIS

SELECT
	emp_length AS Employement_Length,
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Received_Amount
FROM loan
GROUP BY emp_length
ORDER BY emp_length;


			--------------------------------------------------------------------------
			--------------------------------------------------------------------------


-- J) LOAN PURPOSE ANALYSIS

SELECT
	purpose AS Purpose,
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Received_Amount
FROM loan
GROUP BY purpose
ORDER BY purpose;


			--------------------------------------------------------------------------
			--------------------------------------------------------------------------


-- K) HOME-OWNERSHIP ANALYSIS

SELECT
	home_ownership AS Home_Ownership,
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Received_Amount
FROM loan
GROUP BY home_ownership
ORDER BY home_ownership;

















































