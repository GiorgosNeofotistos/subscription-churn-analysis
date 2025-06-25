SELECT SubscriptionType, COUNT(*) AS customers_count, AVG(MonthlyCharges) AS avg_monthly_charge
FROM `subscription-churn-2025.subscription_churn_2025.customers`
GROUP BY SubscriptionType
ORDER BY customers_count DESC;

#1. Basic Exploration
#1.1 Σύνολο εγγραφών (πελατών)
SELECT count(Distinct CustomerID) AS total_customers
FROM `subscription-churn-2025.subscription_churn_2025.customers`;

#1.2 Διανομή ανά Subscription Type
SELECT SubscriptionType,COUNT(*) AS NumberOfCustomers
FROM `subscription-churn-2025.subscription_churn_2025.customers`
GROUP BY SubscriptionType
ORDER BY NumberOfCustomers DESC;

#1.3 Ποσοστά Churn συνολικά & ανά τύπο συνδρομής
SELECT
  total.SubscriptionType,
  total.TotalCustomers,
  churned.ChurnedCustomers,
  ROUND(churned.ChurnedCustomers * 100.0 / total.TotalCustomers, 2) AS ChurnRate_Percentage
FROM (
  SELECT
    SubscriptionType,
    COUNT(CustomerID) AS TotalCustomers
  FROM
    `subscription-churn-2025.subscription_churn_2025.customers`
  GROUP BY
    SubscriptionType
) AS total
LEFT JOIN (
  SELECT
    SubscriptionType,
    COUNT(CustomerID) AS ChurnedCustomers
  FROM
    `subscription-churn-2025.subscription_churn_2025.customers`
  WHERE
    Churn = 1
  GROUP BY
    SubscriptionType
) AS churned
ON total.SubscriptionType = churned.SubscriptionType
ORDER BY ChurnRate_Percentage DESC;

#1.4 Πλήθος και ποσοστό Nulls ανά στήλη
# Η ανάλυση για missing values (NULLs) θα γίνει κατά το data cleaning στο Python


#2. Churn vs. Subscription & Financials
#2.1 Μέσο Monthly Charges και Total Charges ανά Churn status
SELECT Churn, ROUND(AVG(MonthlyCharges)) AS AvgMonthlyCharges, ROUND(AVG(TotalCharges)) AS AvgTotealCharges
FROM subscription-churn-2025.subscription_churn_2025.customers
GROUP BY Churn
ORDER BY Churn DESC;

#2.2 Ποσοστά Churn ανά PaymentMethod
WITH total_customers AS (
  SELECT 
    PaymentMethod,
    COUNT(*) AS TotalCustomers
  FROM 
    `subscription-churn-2025.subscription_churn_2025.customers`
  GROUP BY 
    PaymentMethod
),

churned_customers AS (
  SELECT 
    PaymentMethod,
    COUNT(*) AS ChurnedCustomers
  FROM 
    `subscription-churn-2025.subscription_churn_2025.customers`
  WHERE 
    Churn = 1
  GROUP BY 
    PaymentMethod
)

SELECT 
  t.PaymentMethod,
  t.TotalCustomers,
  COALESCE(c.ChurnedCustomers, 0) AS ChurnedCustomers,
  ROUND(COALESCE(c.ChurnedCustomers, 0) * 100.0 / t.TotalCustomers, 2) AS ChurnRate_Percent
FROM 
  total_customers t
LEFT JOIN 
  churned_customers c
ON 
  t.PaymentMethod = c.PaymentMethod
ORDER BY 
  ChurnRate_Percent DESC;

  #2.3 Επηρεάζει το PaperlessBilling το Churn;
WITH total_customers AS (
  SELECT 
    PaperlessBilling, 
    COUNT(*) AS TotalCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  GROUP BY PaperlessBilling
),
churned_customers AS(
  SELECT 
    PaperlessBilling, 
    COUNT(*) AS ChurnedCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  WHERE Churn = 1
  GROUP BY PaperlessBilling
)
SELECT 
  t.PaperlessBilling,
  t.TotalCustomers,
  COALESCE(c.ChurnedCustomers, 0) AS ChurnedCustomers,
  ROUND(COALESCE(c.ChurnedCustomers, 0) * 100.0 / t.TotalCustomers, 2) AS ChurnRate_Percent
FROM 
  total_customers t
LEFT JOIN 
  churned_customers c
ON 
  t.PaperlessBilling = c.PaperlessBilling
ORDER BY 
  ChurnRate_Percent DESC;

#3. Churn vs. Engagement
#3.1 Viewing Hours ανά Churn status
 SELECT Churn, AVG(ViewingHoursPerWeek) AS AvgViewingHours
FROM `subscription-churn-2025.subscription_churn_2025.customers`
GROUP BY Churn;

#3.2 Content Type (Movies, TV Shows, Both) vs. Churn
WITH total_customers AS (
  SELECT
    ContentType,
    COUNT(*) AS TotalCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  GROUP BY ContentType
),

churned_customers AS (
  SELECT 
    ContentType,
    COUNT(*) AS ChurnedCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  WHERE Churn = 1
  GROUP BY ContentType
)

SELECT 
  t.ContentType,
  t.TotalCustomers,
  COALESCE(c.ChurnedCustomers, 0) AS ChurnedCustomers,
  ROUND(COALESCE(c.ChurnedCustomers, 0) * 100.0 / t.TotalCustomers, 2) AS ChurnRate_Percent
FROM total_customers t
LEFT JOIN churned_customers c
  ON t.ContentType = c.ContentType
ORDER BY ChurnRate_Percent DESC;

#3.3 Genre Preference vs. Churn
WITH total_customers AS (
 SELECT
 GenrePreference, COUNT(*) AS TotalCustomers
FROM subscription-churn-2025.subscription_churn_2025.customers
GROUP BY GenrePreference
),
churned_customers AS (
SELECT 
GenrePreference, COUNT(*) AS ChurnedCustomers
FROM subscription-churn-2025.subscription_churn_2025.customers
WHERE Churn = 1
GROUP BY GenrePreference
)
SELECT t.GenrePreference , t.TotalCustomers,
COALESCE(c.ChurnedCustomers, 0) AS ChurnedCustomers,
ROUND(COALESCE(c.ChurnedCustomers, 0) * 100.0 / t.TotalCustomers, 2) AS ChurnRate_Percent
FROM total_customers t
LEFT JOIN churned_customers c
ON t.GenrePreference = c.GenrePreference
ORDER BY ChurnRate_Percent;

#3.4 Watchlist Size vs. Churn (ή binning σε κατηγορίες)
SELECT Churn, AVG(WatchlistSize) AS AvgWatchlistSize
FROM subscription-churn-2025.subscription_churn_2025.customers
GROUP BY Churn;

#binning
SELECT
  Churn,
  CASE
    WHEN WatchlistSize <= 5 THEN 'Low'
    WHEN WatchlistSize <= 10 THEN 'Medium'
    ELSE 'High'
  END AS WatchlistCategory,
  COUNT(*) AS CustomersCount
FROM
  `subscription-churn-2025.subscription_churn_2025.customers`
WHERE Churn = 1
GROUP BY
  Churn,
  WatchlistCategory
ORDER BY
  Churn,
  WatchlistCategory;

  WITH WatchlistBins AS (
  SELECT
    CustomerID,
    Churn,
    CASE
      WHEN WatchlistSize <= 5 THEN 'Low'
      WHEN WatchlistSize <= 10 THEN 'Medium'
      ELSE 'High'
    END AS WatchlistCategory
  FROM
    `subscription-churn-2025.subscription_churn_2025.customers`
),

TotalPerBin AS (
  SELECT
    WatchlistCategory,
    COUNT(*) AS TotalCustomers
  FROM
    WatchlistBins
  GROUP BY
    WatchlistCategory
),

ChurnedPerBin AS (
  SELECT
    WatchlistCategory,
    COUNT(*) AS ChurnedCustomers
  FROM
    WatchlistBins
  WHERE
    Churn = 1
  GROUP BY
    WatchlistCategory
)

SELECT
  t.WatchlistCategory,
  t.TotalCustomers,
  COALESCE(c.ChurnedCustomers, 0) AS ChurnedCustomers,
  ROUND(COALESCE(c.ChurnedCustomers, 0) * 100.0 / t.TotalCustomers, 2) AS ChurnRate_Percent
FROM
  TotalPerBin t
LEFT JOIN
  ChurnedPerBin c
ON
  t.WatchlistCategory = c.WatchlistCategory
ORDER BY
  ChurnRate_Percent DESC;

#3.5 SubtitlesEnabled & ParentalControl vs. Churn
#SubtitlesEnabled
WITH total_customers AS (
  SELECT 
    SubtitlesEnabled,
    COUNT(*) AS TotalCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  GROUP BY SubtitlesEnabled
),

churned_customers AS (
  SELECT 
    SubtitlesEnabled,
    COUNT(*) AS ChurnedCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  WHERE Churn = 1
  GROUP BY SubtitlesEnabled
)

SELECT 
  t.SubtitlesEnabled,
  t.TotalCustomers,
  COALESCE(c.ChurnedCustomers, 0) AS ChurnedCustomers,
  ROUND(COALESCE(c.ChurnedCustomers, 0) * 100.0 / t.TotalCustomers, 2) AS ChurnRate_Percent
FROM total_customers t
LEFT JOIN churned_customers c
  ON t.SubtitlesEnabled = c.SubtitlesEnabled
ORDER BY SubtitlesEnabled;

#ParentalControl
WITH total_customers AS (
  SELECT 
    ParentalControl,
    COUNT(*) AS TotalCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  GROUP BY ParentalControl
),

churned_customers AS (
  SELECT 
    ParentalControl,
    COUNT(*) AS ChurnedCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  WHERE Churn = 1
  GROUP BY ParentalControl
)

SELECT
  t.ParentalControl,
  t.TotalCustomers,
  COALESCE(c.ChurnedCustomers, 0) AS ChurnedCustomers,
  ROUND(COALESCE(c.ChurnedCustomers, 0) * 100.0 / t.TotalCustomers, 2) AS ChurnRate_Percent
FROM total_customers t
LEFT JOIN churned_customers c
  ON t.ParentalControl = c.ParentalControl
ORDER BY ParentalControl;

#4. Churn vs. User Ratings & Support
#4.1 User Rating ανά Churn status
SELECT 
  Churn, 
  AVG(UserRating) AS AverageRating, 
  COUNT(*) AS TotalCustomers
FROM `subscription-churn-2025.subscription_churn_2025.customers`
GROUP BY Churn
ORDER BY AverageRating;

#4.2 Support Tickets per Month vs. Churn
SELECT 
  Churn, 
  AVG(SupportTicketsPerMonth) AS AvgSupportTickets,
  COUNT(*) AS TotalCustomers
FROM `subscription-churn-2025.subscription_churn_2025.customers`
GROUP BY Churn
ORDER BY AvgSupportTickets DESC;

#5. Device Analysis
#5.1 Ποια Devices χρησιμοποιούνται περισσότερο από churned users;
WITH total_customers AS (
  SELECT DeviceRegistered, COUNT(*) AS TotalCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  GROUP BY DeviceRegistered
),
churned_customers AS (
  SELECT DeviceRegistered, COUNT(*) AS ChurnedCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  WHERE Churn = 1 
  GROUP BY DeviceRegistered
)

SELECT 
  t.DeviceRegistered, 
  t.TotalCustomers,
  COALESCE(c.ChurnedCustomers, 0) AS ChurnedCustomers,
  ROUND(COALESCE(c.ChurnedCustomers, 0) * 100.0 / t.TotalCustomers, 2) AS ChurnRate_Percent
FROM total_customers t
LEFT JOIN churned_customers c
  ON t.DeviceRegistered = c.DeviceRegistered
ORDER BY t.DeviceRegistered;

#5.2 MultiDeviceAccess vs. Churn
WITH total_customers AS (
  SELECT MultiDeviceAccess, COUNT(*) AS TotalCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  GROUP BY MultiDeviceAccess
),
churned_customers AS (
  SELECT MultiDeviceAccess, COUNT(*) AS ChurnedCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  WHERE Churn = 1
  GROUP BY MultiDeviceAccess
)

SELECT 
  t.MultiDeviceAccess, 
  t.TotalCustomers,
  COALESCE(c.ChurnedCustomers, 0) AS ChurnedCustomers,
  ROUND(COALESCE(c.ChurnedCustomers, 0) * 100.0 / t.TotalCustomers, 2) AS ChurnRatePercent
FROM total_customers t
LEFT JOIN churned_customers c
  ON t.MultiDeviceAccess = c.MultiDeviceAccess
ORDER BY t.MultiDeviceAccess;

#6. Demographics
#6.1 Gender vs. Churn
WITH total_customers AS (
  SELECT Gender, COUNT(*) AS TotalCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  GROUP BY Gender
),
churned_customers AS(
  SELECT Gender, COUNT(*) AS ChurnedCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  WHERE Churn = 1
  GROUP BY Gender
)
SELECT t.TotalCustomers, t.Gender,
COALESCE(c.ChurnedCustomers, 0) AS ChurnedCustomers,
ROUND(COALESCE(c.ChurnedCustomers, 0) * 100.0 / t.TotalCustomers, 2) AS ChurnRatePercent
FROM total_customers t
LEFT JOIN churned_customers c
ON t.Gender = c.Gender
ORDER BY Gender;

#6.2 Account Age (σε bins) vs. Churn
WITH total_customers AS (
  SELECT
  CASE WHEN AccountAge <= 6 THEN 'NEW'
  WHEN AccountAge <= 12 THEN 'MID'
  ELSE 'LOYAL'
  END AS AgeCategory,
  COUNT(*) AS TotalCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  GROUP BY AgeCategory
),
churned_customers AS (
  SELECT
  CASE WHEN AccountAge <= 6 THEN 'NEW'
  WHEN AccountAge <= 12 THEN 'MID'
  ELSE 'LOYAL'
  END AS AgeCategory,
  COUNT(*) AS ChurnedCustomers
  FROM `subscription-churn-2025.subscription_churn_2025.customers`
  WHERE Churn = 1
  GROUP BY AgeCategory
)
SELECT 
  t.AgeCategory,
  t.TotalCustomers,
  COALESCE(c.ChurnedCustomers, 0) AS ChurnedCustomers,
  ROUND(COALESCE(c.ChurnedCustomers, 0) * 100.0 / t.TotalCustomers, 2) AS ChurnRate_Percent
FROM total_customers t
LEFT JOIN churned_customers c
  ON t.AgeCategory = c.AgeCategory
ORDER BY AgeCategory;