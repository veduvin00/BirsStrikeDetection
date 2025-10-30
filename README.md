# 🦅 Bird Strike Impact Prediction using AI Models

> Predicting aircraft damage severity from bird strike incidents using data-driven AI models

---

## 📘 Overview
This project develops an AI model to **predict the level of aircraft damage** resulting from bird strikes.  
By leveraging data from real-world wildlife strike reports, it helps aviation authorities and airlines enhance **risk assessment**, **preventive planning**, and **flight safety operations**.

---

## 🚨 Business Problem
A *wildlife strike* occurs when an aircraft collides with an animal — usually a bird — during flight, take-off, or landing.  
These incidents can lead to costly repairs, flight delays, and safety risks.

**Key Statistics**
- 💸 Global annual cost: **~USD 1.26 billion**
- ✈️ One U.S. airline (1999):  
  - 1,326 strikes  
  - USD 6.2 M in repair costs  
  - USD 46.45 M in delay costs  

> 🧩 Objective: Build an AI-based damage prediction model to support data-driven aviation safety decisions.

---

## 📊 Dataset
**Source:** [Aircraft Wildlife Strikes 1990-2023 – Kaggle](https://www.kaggle.com/datasets/dianaddx/aircraft-wildlife-strikes-1990-2023)

**Features include:**
- Bird species & size  
- Flight phase  
- Number of birds struck  
- Aircraft type  
- Location (latitude, longitude)  
- Damage level  

---

## 🧩 Methodology

### 🧹 1. Data Preparation
- Dropped columns with **> 70 % missing values**
- Removed remaining rows with nulls
- Engineered features:
  - `AIRCRAFT_FAMILY`
  - `DAMAGE_LEVEL_GROUPED` *(merged M/M?, N, S/D/S_D)*

### 🌍 2. Exploratory Data Analysis (EDA)
- **Geospatial Analysis:**  
  Bird-strike hotspots concentrated in North America, Europe, and East/Southeast Asia — near major migratory flyways and busy airports.
- **Monetary Impact:**  
  Highest costs during *Arrival*, *Climb*, *Take-off Run*, and *Landing Roll*.
- **Injury Analysis:**  
  *En Route* and *Approach* phases show maximum injuries.
- **Frequency Distribution:**  
  Approach and Landing Roll phases most frequent.

### 🧠 3. Feature Engineering
- **Cyclic Encoding:**  
  Added `MONTH_SIN` and `MONTH_COS` to represent seasonal patterns.
- **Location Clustering:**  
  Applied *K-Means* on latitude/longitude to create `LOCATION_CLUSTER`.  
  Optimal **k = 2** determined via *Elbow* and *Silhouette* methods.

### ⚙️ 4. Model Experimentation

| Model | Key Predictors | Accuracy | Notes |
|-------|----------------|-----------|-------|
| Logistic Regression | Bird size, # struck, flight phase | — | Good interpretability |
| CART | Incident context > technical features | — | Useful for rule-based insights |
| Random Forest | Bird size & incident factors | **68 %** | ✅ *Best performance* |
| XGBoost | Similar to RF but slight drop post-FE | — | Trade-off between recall & precision |

---

## 🧾 Results
- **Best Model:** Random Forest (68 % accuracy)  
- **Recall (Severe Damage):** 0.88 → prioritizes safety  
- **Feature Engineering Impact:** Improved Random Forest performance, minor drops in others  
- **Key Variables:** Bird size, Flight phase, # birds struck, Location cluster  

---

## ⚙️ Challenges
1. Highly **unstructured dataset** with many missing values  
2. **Limited aviation domain knowledge**, restricting domain-specific features  
3. **Class imbalance** impacting fairness and precision  

---

## 🚀 Future Scope
- Integrate **weather**, **bird species**, and **pilot/ATC inputs**  
- Collaborate with **aviation experts** for richer features  
- Test **ensemble or hybrid models**  
- Extend to **general aircraft damage prediction** beyond bird strikes  

---

## 👥 Contributors
- **Liu Ranyan**  
- **Shen Wenquan**  
- **Tan Hsiangwen**  
- **Qin Junying**  
- **Jia Litong**  
- **Vedika Vinod**

---

## 📚 References
1. [SKYbrary – Wildlife Strike](https://skybrary.aero/articles/wildlife-strike)  
2. Allan, J. R. *The Costs of Bird Strikes and Bird Strike Prevention.* USDA APHIS.  
3. Dorobantu, D. M. *Aircraft Wildlife Strikes 1990–2023 Dataset.* Kaggle.  

---


