import numpy as no
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

#Εισάγω τα δεδομένα μου
file_path = r"C:\Users\George\Desktop\subscription_Churn_Project\Subscription_Service_Churn_Dataset.csv"
df = pd.read_csv(file_path)

#Επιθεώρηση Δεδομένων
print(df.info())
print(df.head())
print(df.describe())

#Καθαρισμός τιμών
print(df.isnull().sum())

#1. Drop στήλες με πάρα πολλά missing (π.χ. SubtitlesEnabled)
df.drop(columns=['SubtitlesEnabled'], inplace=True)

#2. Fill NaNs σε ονομαστικές (categorical) με 'Unknown'
categorical_cols = ['SubscriptionType', 'PaymentMethod', 'DeviceRegistered', 'GenrePreference', 'Gender']
df[categorical_cols] = df[categorical_cols].fillna('Unknown')

#3. Fill NaNs σε αριθμητικές με τον μέσο όρο (ή median)
df['MonthlyCharges'].fillna(df['MonthlyCharges'].mean(), inplace=True)
df['TotalCharges'].fillna(df['TotalCharges'].mean(), inplace=True)
df['UserRating'].fillna(df['UserRating'].mean(), inplace=True)

#Επιβεβαίωση ότι δεν υπάρχουν NaNs
print(df.isnull().sum().sort_values(ascending=False))


#Έλεγχος για duplicates με βάση το CustomerID
duplicate_rows = df[df.duplicated(subset='CustomerID',keep=False)]
print(f"Πλήθος διπλότυπων εγγραφών:  {duplicate_rows.shape[0]}")
print(duplicate_rows)

#Δημιουργία κατηγορίας AccountAge
def categorize_account_age(age):
    if age < 30:
        return 'NEW'
    elif age < 90:
        return 'MID'
    else:
        return 'LOYAL'

df['AgeCategory'] = df['AccountAge'].apply(categorize_account_age)

print(df['AgeCategory'].value_counts())

#Clustering των Churners
df_churners = df[df['Churn'] ==1]
print(df_churners.shape)
print(df_churners.head())

#Επιλογή χαρακτηριστικών(features) για clustering
features = [
    'AccountAge', 'MonthlyCharges', 'ViewingHoursPerWeek', 'UserRating', 'WatchlistSize', 'SupportTicketsPerMonth'
]
df_churners_features = df_churners[features]
print(df_churners_features.head())

# Missing values ανά feature στα churners
print(df_churners_features.isnull().sum())

features = ['ViewingHoursPerWeek', 'UserRating', 'WatchlistSize', 'SupportTicketsPerMonth', 'AccountAge', 'MonthlyCharges']
X = df_churners[features]

#Scaling(StandardScaler
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

#KMeans Clustering
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

# Υπολογίζουμε την αδράνεια (inertia) για διάφορα K
inertia = []
K_range = range(1, 11)

for k in K_range:
    kmeans = KMeans(n_clusters=k, random_state=42)
    kmeans.fit(X_scaled)
    inertia.append(kmeans.inertia_)

# Οπτικοποιούμε
plt.figure(figsize=(8, 5))
plt.plot(K_range, inertia, marker='o')
plt.xlabel('Αριθμός Clusters (k)')
plt.ylabel('Inertia')
plt.title('Elbow Method για επιλογή του k')
plt.grid(True)
plt.show()

#Εφαρμογή ΚMeans
from sklearn.cluster import KMeans

# Ορισμός μοντέλου με 5 clusters
kmeans = KMeans(n_clusters=5, random_state=42)

# Εκπαίδευση του μοντέλου
cluster_labels = kmeans.fit_predict(X_scaled)

# Προσθήκη των labels στο DataFrame
df_churners['Cluster'] = cluster_labels

#Έλεγχος αποτελεσμάτων
# Πόσους churners έχει κάθε cluster;
print(df_churners['Cluster'].value_counts())

# Μέσος όρος χαρακτηριστικών ανά cluster
print(df_churners.groupby('Cluster')[features].mean())


#Predictive Modeling
features = ['AccountAge', 'MonthlyCharges', 'ViewingHoursPerWeek', 'UserRating', 'WatchlistSize',
            'SupportTicketsPerMonth', 'SubscriptionType', 'PaymentMethod', 'DeviceRegistered', 'GenrePreference', 'Gender', 'AgeCategory']
target = 'Churn'

X = df[features]  # X = όλα τα χαρακτηριστικά που θα χρησιμοποιήσουμε
y = df[target]    # y = η στήλη που θέλουμε να προβλέψουμε

categorical_cols = ['SubscriptionType', 'PaymentMethod', 'DeviceRegistered', 'GenrePreference', 'Gender', 'AgeCategory']

X_encoded = pd.get_dummies(X, columns=categorical_cols, drop_first=True)

from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    X_encoded, y, test_size=0.2, random_state=42, stratify=y)

from sklearn.ensemble import RandomForestClassifier

# Δημιουργούμε το μοντέλο
rf = RandomForestClassifier(n_estimators=100, random_state=42)

# Εκπαιδεύουμε το μοντέλο στα δεδομένα εκπαίδευσης
rf.fit(X_train, y_train)

from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score

# Κάνουμε προβλέψεις (labels) στο test set
y_pred = rf.predict(X_test)

# Κάνουμε προβλέψεις πιθανοτήτων (για ROC-AUC)
y_proba = rf.predict_proba(X_test)[:, 1]

# Αναφορά ταξινόμησης (precision, recall, f1-score)
print("Classification Report:")
print(classification_report(y_test, y_pred))

# Μήτρα σύγχυσης (confusion matrix)
print("Confusion Matrix:")
print(confusion_matrix(y_test, y_pred))

# ROC-AUC score (πόσο καλά διαχωρίζει τις κλάσεις)
print("ROC-AUC Score:", roc_auc_score(y_test, y_proba))

from sklearn.ensemble import RandomForestClassifier

rf_balanced = RandomForestClassifier(
    n_estimators=100,
    random_state=42,
    class_weight='balanced'
)

rf_balanced.fit(X_train, y_train)

# Προβλέψεις και αξιολόγηση
y_pred_balanced = rf_balanced.predict(X_test)
y_proba_balanced = rf_balanced.predict_proba(X_test)[:, 1]

from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score

print("Classification Report with class_weight='balanced':")
print(classification_report(y_test, y_pred_balanced))

print("Confusion Matrix:")
print(confusion_matrix(y_test, y_pred_balanced))

print("ROC-AUC Score:", roc_auc_score(y_test, y_proba_balanced))



# Δημιουργούμε αντίγραφο του αρχικού DataFrame
df_export = df.copy()

# Προσθέτουμε προβλέψεις από το μοντέλο
df_export['Churn_Predicted'] = rf_balanced.predict(X_encoded)

# Προσθέτουμε Cluster ΜΟΝΟ στους churners
df_export['Churn_Cluster'] = None
df_export.loc[df_export['Churn'] == 1, 'Churn_Cluster'] = df_churners['Cluster'].values

# Αποθήκευση ως CSV στην επιφάνεια εργασίας
df_export.to_csv(r"C:\Users\George\Desktop\subscription_Churn_Project\tableau_final_data.csv", index=False)
