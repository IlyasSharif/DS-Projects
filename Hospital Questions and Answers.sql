-- Solutions to the SQL Hospital Database
-- Database available from wikipedia, questions from w3resource.com

USE `Hospital`;

-- 1. Find out which nurses have not yet been registered. Return all fields of the nurse table.
SELECT * FROM nurse WHERE registered=False;

-- 2. Identify the nurses in charge of each department. Return the nursename and position.
SELECT Name, Position FROM nurse WHERE position LIKE '%Head%';

-- 3. Identify the physicians who are the department heads. Return Department name and Physician Name
SELECT physician.Name AS `Physician`,department.name AS `Department` FROM physician JOIN department ON employeeid = head;

-- 4. Count the number of patients who scheduled an appointment with at least one physician. Return count as "Number of patients taken at least one appointment"
SELECT COUNT(DISTINCT(Patient)) AS `Number of patients taken at least one appointment` FROM appointment;

-- 5. Locate the floor and block where room number 212 is located. Return block floor as "floor" and block code as "block".
SELECT BlockFloor AS `Floor`, BlockCode AS `Block` FROM room WHERE RoomNumber=212;

-- 6. Count the number of available rooms. Return count as "Number of available rooms"
SELECT Count(*) AS `Number of available rooms` FROM room WHERE Unavailable=False;

-- 7. Count the number of unavailable rooms. Return count as "Number of unavailable rooms"
SELECT Count(*) AS `Number of unavailable rooms` FROM room WHERE Unavailable=True;

-- 8. Identify the physician and the department with which he or she is affiliated.
SELECT physician.Name as `Name`, department.name AS `Department`, position FROM physician 
	JOIN affiliated_with ON physician.employeeid = affiliated_with.physician 
    JOIN department ON affiliated_with.department = department.departmentid;
    
-- 9. Find those physicians who have received special training. Return physician name, treatment procedure.
SELECT physician.Name AS `Name`, procedures.Name As `Treatment` FROM physician 
	JOIN trained_in ON physician = employeeid
    JOIN procedures ON treatment = code
    ORDER BY `Name`;
    
-- 10. Find those physicians who are yet to be affiliated. Return physician name, position and department.
SELECT physician.Name as `Name`, department.name AS `Department`, position FROM physician 
	JOIN affiliated_with ON physician.employeeid = affiliated_with.physician 
    JOIN department ON affiliated_with.department = department.departmentid
    WHERE primaryaffiliation=False;

-- 11. Identify physicians who are not specialists. Return physician name, position.
SELECT name,position  FROM physician 
	WHERE physician.Name NOT IN (SELECT DISTINCT(physician.Name) AS `Name` FROM physician 
								 JOIN trained_in ON physician = employeeid);
                                 
-- 12. Find the patients with their physicians by whom they recieved preliminary treatment. Return physician name, patient name & address.
SELECT patient.Name, patient.Address, physician.name AS `Physician` FROM patient 
    JOIN physician ON physician.employeeid = patient.pcp;
    
-- 13. Identify the patients and the number of physicians with whom they have scheduled appoints. Return patient name, number of physicians.
SELECT patient.name AS `Name`, COUNT(patient.name) AS `Appointmnet for No. of Physicians`
	FROM patient 
	JOIN appointment ON patient.SSN = appointment.patient
    GROUP BY patient.name;
    
-- 14. Count the number of unique patients who have been scheudle for examination room 'C'. Return unique patients as "No. of patients got appointment for room C".
SELECT COUNT(DISTINCT(patient)) AS "No. of patients got appointment for room C" FROM appointment WHERE examinationRoom='C';

-- 15. Find the names of the patients and the room number where they need to be treated. Return patient name, examination room, starting date time.
SELECT Name, starto, examinationroom FROM patient JOIN appointment ON ssn = patient;

-- 16. Identify the nurses and the room in which they will assist the physicians. Return nurse name and examination room.
SELECT nurse.name AS `Name`, examinationRoom FROM nurse 
	JOIN undergoes ON employeeid = assistingnurse 
    JOIN appointment ON appointment.patient = undergoes.patient;

-- 17. Locate the patients who attended the appointment on the 25th of April at 10 am. Return patient name, name of nurse, physician, examination room, schedule date.
SELECT patient.name AS patient, physician.name AS physician, nurse.name AS nurse, starto, examinationroom FROM appointment 
	JOIN patient ON ssn = patient 
    JOIN nurse ON nurse.employeeid = prepnurse
    JOIN physician ON physician.employeeid=physician
    WHERE MONTH(Starto)=4 AND DAY(Starto)=25 AND TIME(Starto)='10:00:00';
    
-- 18. Identify those patients and their physicians who do not require any nursing assistnace. Return patient name, physician, examination room.
SELECT patient.name AS patient, physician.name AS physician, examinationroom FROM appointment 
	JOIN patient ON ssn = patient 
    JOIN physician ON physician.employeeid=physician
    WHERE prepNurse IS NULL;
    
-- 19. Locate the patients their physicians and their medications.
SELECT patient.name AS patient, physician.name as physician, medication.name FROM prescribes
	JOIN patient ON prescribes.patient = patient.ssn
	JOIN physician ON physician.employeeid=physician
    JOIN medication ON medication.code = prescribes.medication;
    
-- 20. Identify patients who have made an advancded appointment. Return patient name, physician, medication name.
SELECT patient.name AS patient, physician.name as physician, medication.name FROM prescribes
	JOIN patient ON prescribes.patient = patient.ssn
	JOIN physician ON physician.employeeid=physician
    JOIN medication ON medication.code = prescribes.medication
    WHERE prescribes.appointment IS NOT NULL;
    
-- 21. Find patients who did not schedule an appointment. Return patient name, physician name, medication name.
SELECT patient.name AS patient, physician.name as physician, medication.name FROM prescribes
	JOIN patient ON prescribes.patient = patient.ssn
	JOIN physician ON physician.employeeid=physician
    JOIN medication ON medication.code = prescribes.medication
    WHERE prescribes.appointment IS NULL;
    
-- 22. Count the number of available rooms in each blockcode. Sort the result-set on ID of block. Return ID of block, count number of available rooms.
SELECT Blockcode, COUNT(RoomNumber) AS `number of available rooms` FROM ROOM 
	WHERE Unavailable=False
    GROUP BY Blockcode
    ORDER BY blockcode;

-- 23. Count the number of available rooms in each floor. Sort by block floor. Return floor id and count number of available rooms.
SELECT Blockfloor, COUNT(RoomNumber) AS `number of available rooms` FROM ROOM 
	WHERE Unavailable=False
    GROUP BY Blockfloor
    ORDER BY blockfloor;
    
-- 24. Count the number of available rooms for each floor in each block. Sort the results on floor id, id of block.
SELECT Blockfloor, Blockcode, COUNT(RoomNumber) AS `number of available rooms` FROM ROOM 
	WHERE Unavailable=False
    GROUP BY Blockcode, Blockfloor
    ORDER BY Blockfloor, Blockcode;
    
-- 25. Count the number of rooms that are unavailable in each block and on each floor. 
SELECT Blockfloor, Blockcode, COUNT(RoomNumber) AS `number of unavailable rooms` FROM ROOM 
	WHERE Unavailable=True
    GROUP BY Blockcode, Blockfloor
    ORDER BY Blockfloor, Blockcode;
    
-- 26. Find the floor where the maximum number of rooms are available. Return floor ID, count "number of available rooms".
SELECT Blockfloor, COUNT(RoomNumber) AS `number of available rooms` FROM ROOM 
	WHERE Unavailable=False
    GROUP BY Blockfloor HAVING COUNT(RoomNumber)= (SELECT max(maxRooms) FROM 
													(SELECT blockfloor, count(*) AS maxRooms 
                                                    FROM room WHERE unavailable=False GROUP BY blockfloor) 
                                                    AS derived);
                                                    
-- 27. Locate the floor with the minimum number of available rooms. Return floor ID, count "number of available rooms".
SELECT Blockfloor, COUNT(RoomNumber) AS `number of available rooms` FROM ROOM 
	WHERE Unavailable=False
    GROUP BY Blockfloor HAVING COUNT(RoomNumber)= (SELECT MIN(maxRooms) FROM 
													(SELECT blockfloor, count(*) AS maxRooms 
                                                    FROM room WHERE unavailable=False GROUP BY blockfloor) 
                                                    AS derived);
                                                    
-- 28. Find the name of patients, their block, floor, and room number where they were admitted.
SELECT name, blockfloor, blockcode, room FROM patient
	JOIN stay ON ssn = patient
    JOIN room ON roomnumber = room;

-- 29. Locate the nurses and the block where they are scheduled to attend the on-call patients.
SELECT name, blockcode FROM nurse JOIN on_call ON employeeid = nurse;

-- 30. Get a) name of patient, b) name of physician who is treating them, c) name of attending nurse, d) patient medication, e) date of release, f) room/floor/block admitted
SELECT patient.name AS `Patient`, physician.name AS `physician`, nurse.name AS `nurse`, stay.Stayend, procedures.name AS `procedure`, room.roomnumber, room.blockfloor, room.blockcode
	FROM undergoes
	JOIN patient ON patient.ssn = undergoes.patient
    JOIN physician ON physician = physician.employeeid
    LEFT JOIN nurse ON assistingnurse = nurse.employeeid
    JOIN stay ON undergoes.patient = stay.patient
    JOIN room ON stay.room = room.roomnumber
    JOIN procedures ON undergoes.procedures = procedures.code;
    
-- 31. Find all physicians who have performmed a medical procedure but are not certified to do so. Return physician name.
SELECT name FROM physician WHERE employeeid IN (SELECT undergoes.physician FROM undergoes 
												LEFT JOIN trained_in ON undergoes.physician = trained_in.physician 
                                                AND undergoes.procedures=trained_in.treatment
												WHERE treatment IS NULL);
                                                
-- 32. Find all physicians, their procedures, the date when the procedure was performed, name of patient it was performed on, but the physicians are not
--     certified to perform that procedure. 
SELECT physician.name AS `Physician`, procedures.name, undergoes.dateundergoes, patient.name AS `Patient` FROM physician 
	JOIN undergoes ON physician.employeeid = undergoes.physician
    JOIN patient ON patient.ssn = undergoes.patient
    JOIN procedures ON procedures.code = undergoes.procedures
	WHERE employeeid IN (SELECT undergoes.physician FROM undergoes 
												LEFT JOIN trained_in ON undergoes.physician = trained_in.physician 
                                                AND undergoes.procedures=trained_in.treatment
												WHERE treatment IS NULL)
	AND patient.ssn IN (SELECT undergoes.patient FROM undergoes 
												LEFT JOIN trained_in ON undergoes.physician = trained_in.physician 
                                                AND undergoes.procedures=trained_in.treatment
												WHERE treatment IS NULL)
	AND undergoes.dateundergoes IN (SELECT undergoes.dateundergoes FROM undergoes 
												LEFT JOIN trained_in ON undergoes.physician = trained_in.physician 
                                                AND undergoes.procedures=trained_in.treatment
												WHERE treatment IS NULL);
                                                
-- 33. Find all physicians who completed a medical procedure with certification after the expiration date of their license.
SELECT name, position FROM physician WHERE employeeid IN (SELECT undergoes.physician FROM undergoes LEFT JOIN trained_in ON undergoes.physician = trained_in.physician
		AND undergoes.procedures=trained_in.treatment WHERE treatment IS NOT NULL AND CertificationExpires<DateUndergoes); 
        
-- 34. Same as 33?

-- 35. Which nurses have been on call for room 122 in the past. Return name of nurses
SELECT nurse.name FROM on_call 
	JOIN room ON (on_call.blockfloor, on_call.blockcode) = (room.blockfloor, room.blockcode) 
    JOIN nurse ON nurse.employeeid = nurse
    WHERE roomNumber = 122;

-- 36. Determine which patients have been prescribed medication by their primary care physician
SELECT patient.name, physician.name FROM patient 
	LEFT JOIN prescribes ON (ssn, pcp) = (patient, physician) 
    JOIN physician ON employeeid = physician
    WHERE patient IS NOT NULL;
    
-- 37. Find patients who have undergone a procedure > $5000, as well as the name of the physician who has provided primary care.
SELECT patient.name, physician.name, procedures.name, cost FROM undergoes
	JOIN procedures ON undergoes.procedures = procedures.code
    JOIN patient on patient.ssn = undergoes.patient
    JOIN physician ON physician.employeeid = patient.pcp
    WHERE cost>5000;

-- 38. Find the patients with atleast two appointments in which the nurse who prepared the appointment was a registered nurse
--     and the physician who provided primary care should be identified. 
SELECT patient.name AS `patient`, physician.name AS `physician`, nurse.name AS `nurse` FROM appointment 
	JOIN nurse ON prepNurse = nurse.employeeid
    JOIN patient ON patient.ssn = patient
    JOIN physician ON pcp = physician.employeeid
    WHERE patient.ssn IN (SELECT patient FROM appointment 
						  GROUP BY patient HAVING COUNT(DISTINCT(AppointmentID)) >= 2)
	AND nurse.registered=True;
    
-- 39. Identify the patients whose primary care is provided by a physician who is not the head of any department.
SELECT patient.name, physician.name FROM patient 
	JOIN physician ON pcp = employeeid
    WHERE pcp NOT IN (SELECT head FROM department);
                          