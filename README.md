# subscription-churn-analysis
## Executive Summary
This project analyzes customer churn patterns in a subscription-based service using SQL, Python, and Tableau. By uncovering key factors driving churn and building predictive models, actionable insights were derived to help reduce customer attrition and improve business retention strategies.

---

## Project Overview
The goal of this project is to understand the factors that contribute to customer churn and provide data-driven recommendations to reduce it. The dataset was sourced from Kaggle and includes customer subscription, engagement, demographic, and support information.

---

## Data Exploration & Analysis

- Used **BigQuery SQL** to perform initial exploration:  
  - Customer counts and churn rates by subscription type, payment method, and engagement metrics  
  - Detailed segmentation by demographics, device usage, and support ticket analysis  

- Conducted **data cleaning and preparation in Python**, including missing value handling, feature engineering, and clustering to segment churners by behavior.

- Created **Tableau dashboards** to visualize KPIs like total customers, churned customers, churn rate percentage, and distribution by subscription type and engagement.

---

## Key Insights

- Subscription types like “Basic” have significantly higher churn rates, indicating potential dissatisfaction or low perceived value.  
- Customers using manual or complex payment methods show increased churn.  
- Low engagement (e.g., fewer viewing hours and smaller watchlists) correlates strongly with churn.  
- High support ticket volume is linked to increased churn risk.  
- Demographics and device preferences influence churn patterns, suggesting opportunities for personalization.

---

## Recommendations

1. Implement targeted retention campaigns based on churn risk segmentation.  
2. Review and optimize subscription plans with high churn rates.  
3. Enhance user engagement via personalized content and loyalty programs.  
4. Improve customer support to reduce friction and ticket volume.  
5. Simplify payment processes to reduce churn linked to billing issues.  
6. Use predictive modeling continuously for early churn detection and intervention.

---

## Technical Stack & Files

- **SQL Queries**: `subscription_churn_analysis.sql` — BigQuery queries for data exploration and aggregation  
- **Python Script**: `churn_analysis.py` — Data cleaning, feature engineering, clustering, and predictive modeling  
- **Tableau Workbook**: `subscription_churn_dashboard.twbx` — Interactive dashboards visualizing key KPIs and churn patterns  
- **Screenshots**: Visual examples of dashboards and charts for quick reference  

---

## About this Project

This work showcases a comprehensive end-to-end churn analysis, combining data engineering, statistical analysis, machine learning, and visualization skills. It demonstrates the ability to translate complex data into actionable business insights.

---

## Acknowledgements

Some assistance was provided by AI tools to optimize coding and analysis workflows, but all business insights and decision-making are original and based on thorough data exploration.

---

## How to Use

1. Review SQL queries in BigQuery to understand initial data aggregation.  
2. Run the Python script for data preprocessing and modeling.  
3. Open the Tableau workbook to interact with the visualizations and KPIs.  
4. Explore the findings and apply recommendations to business strategies.

---

## Contact

For any questions or collaboration inquiries, please contact:  
George Neofotistos – [LinkedIn Profile](https://www.linkedin.com/in/george-neofotistos94)
