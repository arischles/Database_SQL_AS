CREATE TABLE Countries
(
Country_Code INT PRIMARY KEY,
Name VARCHAR(100),
UNIQUE INDEX ( Country_Code )
);

CREATE TABLE Streets
(
Street_Name VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Seas
(
Sea_Name VARCHAR(100) PRIMARY KEY,
Sea_Size INT NOT NULL
);

CREATE TABLE Cities
(
City_Name VARCHAR(100),
Number_of_citizens INT,
Resident_Id INT NOT NULL UNIQUE,
Mayor_Id INT,
Street_Name VARCHAR(100),
Country_Code INT,
PRIMARY KEY (City_Name, Resident_Id),
FOREIGN KEY (Mayor_Id) REFERENCES Cities(Resident_Id),
FOREIGN KEY (Street_Name) REFERENCES Streets(Street_Name),
FOREIGN KEY (Country_Code) REFERENCES Countries(Country_Code)
);

CREATE TABLE CitySeaRelation
(
Sea_Name VARCHAR(100) NOT NULL,
City_Name VARCHAR(100) NOT NULL,
FOREIGN KEY (Sea_Name) REFERENCES Seas(Sea_Name),
FOREIGN KEY (City_Name) REFERENCES Cities(City_Name)
);

INSERT INTO Countries (Country_Code, Name) VALUES (54, "Argentina");
INSERT INTO Countries (Country_Code, Name) VALUES (880, "Bangladesh");
INSERT INTO Countries (Country_Code, Name) VALUES (53, "Cuba");
INSERT INTO Countries (Country_Code, Name) VALUES (33, "France");
INSERT INTO Countries (Country_Code, Name) VALUES (972, "Israel");

INSERT INTO Seas (Sea_Name, Sea_Size) VALUES ("Philippine", 5695000);
INSERT INTO Seas (Sea_Name, Sea_Size) VALUES ("Gulf of Mexico", 1600);
INSERT INTO Seas (Sea_Name, Sea_Size) VALUES ("mediterranean", 2500);
INSERT INTO Seas (Sea_Name, Sea_Size) VALUES ("Hudson Bay", 1);
INSERT INTO Seas (Sea_Name, Sea_Size) VALUES ("Kara", 1);

INSERT INTO Streets (Street_Name) VALUES ("Ben-Gurion Boulevard");
INSERT INTO Streets (Street_Name) VALUES ("Herzl");
INSERT INTO Streets (Street_Name) VALUES ("King George");
INSERT INTO Streets (Street_Name) VALUES ("Bograshov");
INSERT INTO Streets (Street_Name) VALUES ("Bialik");
INSERT INTO Streets (Street_Name) VALUES ("Adar");

INSERT INTO Cities (City_Name, Number_of_citizens, Resident_Id, Mayor_Id, Street_Name, Country_Code) VALUES ("Tel Aviv", 460613, 123, 123, "Herzl", 972);
INSERT INTO Cities (City_Name, Number_of_citizens, Resident_Id, Mayor_Id, Street_Name, Country_Code) VALUES ("Ashdod", 226044, 111, 111, "Herzl", 972);
INSERT INTO Cities (City_Name, Number_of_citizens, Resident_Id, Mayor_Id, Street_Name, Country_Code) VALUES ("Herzliya", 97470, 222, 222, "Bialik", 972);
INSERT INTO Cities (City_Name, Number_of_citizens, Resident_Id, Mayor_Id, Street_Name, Country_Code) VALUES ("Eilat", 84789, 333, 333, "Adar", 972);
INSERT INTO Cities (City_Name, Number_of_citizens, Resident_Id, Mayor_Id, Street_Name, Country_Code) VALUES ("Holon", 192282, 444, 444, "Bialik", 972);

INSERT INTO CitySeaRelation (Sea_Name, City_Name) VALUES ("mediterranean", "Tel Aviv");
INSERT INTO CitySeaRelation (Sea_Name, City_Name) VALUES ("mediterranean", "Ashdod");
INSERT INTO CitySeaRelation (Sea_Name, City_Name) VALUES ("mediterranean", "Herzliya");
INSERT INTO CitySeaRelation (Sea_Name, City_Name) VALUES ("mediterranean", "Eilat");
INSERT INTO CitySeaRelation (Sea_Name, City_Name) VALUES ("mediterranean", "Holon");

DELIMITER $$

CREATE TRIGGER before_city_insert
BEFORE INSERT
ON Cities FOR EACH ROW
BEGIN
	DECLARE cityname VARCHAR(100);
    
	-- Check if mayor is in the table as resident
	IF NEW.Mayor_Id not in (
            select C.Resident_Id
            From Cities C) 
		AND NEW.Mayor_Id != NEW.Resident_Id
	THEN
		CALL `Insert not allowed since mayor is not resident`;
	END IF;
        
	IF NEW.Mayor_Id in (
            select C.Resident_Id
            From Cities C)
	THEN
		SELECT City_Name
		INTO cityname
		FROM Cities
        WHERE Resident_Id = NEW.Mayor_Id;
        IF cityname != NEW.City_Name
        THEN
			CALL `Insert not allowed since mayor is not resident`;
		END IF; 
	END IF;

END $$

DELIMITER ;

CREATE VIEW residentPerCity AS 
SELECT City_Name, COUNT(Resident_Id) AS Resident_Count
FROM Cities
GROUP BY City_Name;
    
SELECT Cities.City_Name, Countries.Name AS Country_Name, SUM(Seas.Sea_Size) AS Sea_Size_Sum, COUNT(Seas.Sea_Name) AS Sea_Count, COUNT(DISTINCT Cities.Street_Name) AS Streets_Count
FROM Cities
INNER JOIN Countries on Cities.Country_Code = Countries.Country_Code
INNER JOIN CitySeaRelation on Cities.City_Name = CitySeaRelation.City_Name
INNER JOIN Seas on Seas.Sea_Name = CitySeaRelation.Sea_Name
Group by Cities.City_Name, Country_Name WITH ROLLUP