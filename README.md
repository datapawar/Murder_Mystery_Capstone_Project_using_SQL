## 🕵️ SQL Murder Mystery: "Who Killed the CEO?"

![SQL](https://img.shields.io/badge/SQL-Investigation-blue)
![CTEs](https://img.shields.io/badge/CTE-Used-success)
![Joins](https://img.shields.io/badge/JOIN-Multi--table-important)
![Status](https://img.shields.io/badge/Case-Solved-brightgreen)

> *A narrative, evidence-driven SQL investigation where every clue lives inside relational tables.*

---

## 📖 Story Background

On **October 15, 2025**, the CEO was found dead in the **CEO Office**, and the entire investigation was solved using SQL.
The script follows a structured, step-by-step approach: define a time window, identify presence, validate alibis, analyze calls, correlate evidence, and intersect findings to isolate a single suspect.

---

## 🗂️ Dataset & Tables

This project treats the database like a forensic system where each table contributes a different type of "evidence."

| Table | Description |
|---|---|
| **employees** | Directory of employees (IDs, names, department, role) |
| **keycard_logs** | Room entry/exit activity used to reconstruct movement timelines |
| **alibis** | Claimed locations + timestamps used to verify (or disprove) statements |
| **calls** | Call records (caller/receiver + time) to detect suspicious activity during the crime window |
| **evidence** | Evidence details (what, where, when found) to connect physical/digital traces to individuals |

---

## 🧭 Investigation Walkthrough (Script Structure)

The SQL file is organized as **STEP → Objective → Investigation → SQL → Disclosure/Result** for readability and storytelling.

### ✅ Step 1: Identify the Crime Window & Presence

The script first searches for any keycard activity overlapping the approximate window **20:30–21:30** on **2025-10-15**, then narrows specifically to the **CEO Office**.
A join to `employees` reveals that **employee_id = 4 (David Kumar)** was present in the CEO Office during the key timeframe (entry around **20:50**, exit around **21:00**).

### ✅ Step 2: Validate Exclusivity of Access

A follow-up query checks who was present in critical rooms (e.g., **CEO Office**, **Server Room**) and verifies that **David Kumar** was the only person in the CEO Office during the crucial period.

### ✅ Step 3: Cross-Check Alibis vs Reality (CTEs)

Using CTEs (`claimed` vs `actual`), the script compares alibis against keycard logs to detect contradictions.
It flags that **David Kumar's alibi conflicts** with keycard movement, indicating a false or misleading claim.

### ✅ Step 4: Analyze Suspicious Calls

Calls within **20:30–21:30** are pulled and joined to `employees` twice to show both caller and receiver names.
The script highlights a call around **21:00** involving David Kumar (a short call to **Alice Johnson**, duration noted as **45 seconds**).

### ✅ Step 5: Evidence Correlation (Who Was Last in the Room?)

Evidence records are connected to room access patterns to determine which employee(s) were associated with evidence locations near discovery time.
The disclosure notes that the evidence trail aligns most strongly with **David Kumar**.

### ✅ Step 6: Final Intersection (The "SQL Verdict")

The final step builds three suspicious sets — presence in CEO Office, alibi mismatch, and calls in the critical window - and intersects them to find the overlap.
This convergence identifies a single killer: **David Kumar**.

---

## 🧪 How to Run

1. **Create / select the database:**
   ```sql
   USE murder_mystery;
   ```

2. **Execute the script file:**
   Run `Murder_Mystery.sql` in your SQL client (MySQL-compatible syntax is used, e.g., `DATE()` and `BETWEEN`).

3. **Check the final output:**
   The last query returns a single-column result: `killer`.

---

## 🧠 Concepts Demonstrated

| Concept | Description |
|---|---|
| **Time-window filtering** | Reconstruct events using `BETWEEN` and overlap logic |
| **Multi-table JOINs** | Enrich raw logs with human-readable identities |
| **CTEs** | Separate "claimed" vs "actual" evidence streams for cleaner reasoning |
| **Evidence-driven storytelling** | Turn tables into a structured narrative with disclosures per step |
| **Set intersection logic** | Isolate the final suspect via CTE pipelines and membership filters |

---

## 🏁 Final Result

### 🔍 Killer Identified: **David Kumar**

The script concludes David Kumar is the killer by combining movement logs, alibi contradictions, call timing, and evidence correlation into a single consistent chain of proof.

---

## 📁 Repository Contents

| File | Description |
|---|---|
| `Murder_Mystery.sql` | Investigation script (steps + queries) |
| `README.md` | Project overview and walkthrough (this file) |

---
