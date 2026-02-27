/* ===========================================================
   SQL Murder Mystery — Investigation Script
   File: Murder_Mystery.sql
   Author: Abhishek Pawar
   Date: 2025-11-29
   Format: STEP → Objective → Investigation → SQL → Disclosure/Result
   =========================================================== */

/* ----------------------------------------------------------------
   STEP 1: Identify where and when the crime happened.
   Objective: Find any presence in the CEO Office near the crime window (approx 20:30-21:30 on 2025-10-15).
   Investigation: Use keycard_logs and filter logs that overlap the crime window.*/
   
use murder_mystery;
SELECT *
FROM keycard_logs
WHERE entry_time <= '2025-10-15 21:30:00'
  AND exit_time  >= '2025-10-15 20:30:00';
  
 -- Disclosure → Upon inspection of keycard_logs it is found that employee_id 4 was present in the CEO's office. 
  
SELECT
    k.*,
    e.name,
    e.department,
    e.role
FROM keycard_logs k
JOIN employees e ON k.employee_id = e.employee_id
WHERE k.room = 'CEO Office'
  AND k.entry_time <= '2025-10-15 21:30:00'
  AND k.exit_time >= '2025-10-15 20:30:00';

/*Disclosure → After checking to whom this ID belongs we have a name "David Kumar". 
			-- He is the only person whose presence was recorded in the CEO's Office 
			   just 10 mins before the CEO's reported time of death. (entry:20:50 -- exit:21:00).
			-- All of these facts make David Kumar a prime suspect for CEO's death.*/

/* ----------------------------------------------------------------
   STEP 2: Analyze who accessed critical areas at the time.
   Objective: Check everyone’s presence around the building and check logs of prime suspect.
   Investigation: JOIN employees to keycard_logs; check if 2025-10-15 20:50:00 is between entry and exit.*/

SELECT e.employee_id,
       e.name,
       k.*
FROM employees AS e
JOIN keycard_logs AS k
  ON e.employee_id = k.employee_id
WHERE k.room IN ('CEO Office', 'Server Room') 
  AND '2025-10-15 21:00:00' BETWEEN k.entry_time AND k.exit_time;

/*Disclosure → Data from keycard_logs shows that between 20:50 to 21:00 the only 
			   person present in CEO's office was David Kumar.
			-- No one else had accessed CEO's Office room at or near this time.
-- This reinforces that only David Kumar had accessed the CEO's office at the reported time of CEO's death .*/

/* ----------------------------------------------------------------
   STEP 3: Cross-check alibis with actual logs.
   Objective: Check if all the employees alibis matches the keycard logs.
  Investigation: Comparing claimed vs Actual location*/

WITH claimed AS ( SELECT * FROM alibis 
WHERE claim_time 
BETWEEN '2025-10-15 20:30:00' 
AND '2025-10-15 21:30:00'), 
actual AS ( SELECT * FROM keycard_logs 
WHERE room = 'CEO Office' 
AND entry_time BETWEEN '2025-10-15 20:30:00' 
AND '2025-10-15 21:30:00') 
SELECT c.employee_id, e.name, 
c.claimed_location, a.room 
AS actual_location FROM 
claimed c JOIN actual a 
ON c.employee_id = a.employee_id JOIN employees e 
ON e.employee_id = c.employee_id;

/*Disclosure → David Kumar's alibi is contradictory to the keycardlogs.
			-- The recorded data shows he was present in CEO's office and is conflicting to his alibi which states he was in server room.
			-- This makes David's alibi incorrect, and heightens suspicion on him.*/

/* ----------------------------------------------------------------
   STEP 4: Investigate suspicious calls made around the time.
   Objective: Identify calls that overlap the window 20:30–21:30 (incoming or outgoing).
  Investigation: compute call end time with DATE_ADD(call_time, INTERVAL duration_sec SECOND).
     Join caller/receiver IDs to employees for names.*/

SELECT
c.*,
caller.name  AS caller_name,
receiver.name AS receiver_name
FROM calls c
JOIN employees caller   ON c.caller_id = caller.employee_id
JOIN employees receiver ON c.receiver_id = receiver.employee_id
WHERE c.call_time BETWEEN '2025-10-15 20:30:00' AND '2025-10-15 21:30:00'
ORDER BY c.call_time;

/*Disclosure: Around 21:00 hrs David calls Alice Johnson and talks for 45 secs.
		   -- This call took place while David was present in the CEO's Office.
           -- The timing and duration of call indicate that he was active during the crime timeframe.*/

/* ----------------------------------------------------------------
   STEP 5: Match evidence with movements and claims.
   Objective: For each evidence collected, find the last person recorded in that room before the
              evidence was found.
  Investigation: Check by pulling together evidence and keycard activity 
				to see which employees were in certain rooms around the time evidence was found.*/

SELECT
    ev.evidence_id,
    ev.room,
    ev.description,
    ev.found_time,
    k.employee_id,
    e.name,
    k.entry_time,
    k.exit_time
FROM evidence ev
LEFT JOIN keycard_logs k
    ON ev.room = k.room
   AND (
        (ev.room = 'CEO Office'
         AND k.entry_time <= ev.found_time
         AND k.exit_time >= '2025-10-15 20:50:00')
        OR
        (ev.room = 'Server Room'
         AND DATE(k.entry_time) = '2025-10-15')
       )
LEFT JOIN employees e
    ON k.employee_id = e.employee_id
WHERE ev.room IN ('CEO Office', 'Server Room')
ORDER BY name;

/* Disclosure: Every piece of evidence including fingerprints and digital traces was last associated with David Kumar.
-- Evidence #1 and #2 directly connect him to the CEO's Office immediately before discovery.
-- Evidence #3 links back to his earlier Server Room access in the morning, disproving his later alibi.*/

/* ----------------------------------------------------------------
   STEP 6: Combine all findings to identify the killer.
   Objective: Find employees who satisfy all three suspicious conditions:
       - Were in CEO Office at 20:50 (movement_match)
       - Gave an alibi at 20:50 that claims a different location (alibi_mismatch)
       - Had a call overlapping 20:50–21:00 (call_overlap)
  Investigation: Return the name(s) of the employee(s) who were in the CEO Office around the time, 
  lied about their location, and made a call in the critical window by building 
  three CTEs and INTERSECT (via JOIN on distinct employee_ids) to get the intersection.*/
WITH present AS (
SELECT employee_id
FROM keycard_logs
WHERE room = 'CEO Office'
AND (entry_time BETWEEN '2025-10-15 20:30:00' AND '2025-10-15 21:30:00'
OR exit_time BETWEEN '2025-10-15 20:30:00' AND '2025-10-15 21:30:00')),
lied AS (
SELECT employee_id
FROM alibis
WHERE claim_time BETWEEN '2025-10-15 20:45:00' AND '2025-10-15 21:15:00'
AND claimed_location != 'CEO Office'),
calls_nearby AS (
SELECT caller_id AS employee_id
FROM calls
WHERE call_time BETWEEN '2025-10-15 20:50:00' AND '2025-10-15 21:05:00'),
suspects AS (
SELECT p.employee_id
FROM present p
WHERE p.employee_id IN (SELECT employee_id FROM lied)
AND p.employee_id IN (SELECT employee_id FROM calls_nearby))
SELECT emp.name AS killer
FROM suspects s JOIN employees emp
ON emp.employee_id = s.employee_id;

/*Disclosure: The convergence of three separate evidence sources— actual presence, a false alibi, 
and incriminating call activity points conclusively to a single person: David Kumar is the killer.*/



