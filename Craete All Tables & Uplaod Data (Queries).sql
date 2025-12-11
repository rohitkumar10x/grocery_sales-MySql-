
                                                    --   ALL TABLE CARETE



CREATE DATABASE Grocery_Sales_Database;
 USE  Grocery_Sales_Database;
 
 CREATE TABLE Countries(
    CountryID INT PRIMARY KEY,
    CountryName VARCHAR(100) NOT NULL,
    CountryCode VARCHAR(10)
);

CREATE TABLE Cities (
    CityID INT PRIMARY KEY,
    CityName VARCHAR(100) NOT NULL,
    Zipcode VARCHAR(20),
    CountryID INT,

    FOREIGN KEY (CountryID) REFERENCES Countries(CountryID)
);


CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(100),
    MiddleInitial VARCHAR(5),
    LastName VARCHAR(100),
    CityID INT,
    Address VARCHAR(255),

    FOREIGN KEY (CityID) REFERENCES Cities(CityID)
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(100),
    MiddleInitial VARCHAR(5),
    LastName VARCHAR(100),
    BirthDate DATE,
    Gender VARCHAR(10),
    CityID INT,
    HireDate DATE,

    FOREIGN KEY (CityID) REFERENCES Cities(CityID)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(150),
    Price DECIMAL(10,2),
    CategoryID INT,
    Class VARCHAR(50),
    ModifyDate DATE,
    Resistant VARCHAR(50),
    IsAllergic VARCHAR(10),
    VitalityDays INT,

    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);



SET FOREIGN_KEY_CHECKS = 0;


CREATE TABLE Sales (
    SalesID INT PRIMARY KEY AUTO_INCREMENT,
    SalesPersonID INT NOT NULL,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT UNSIGNED NOT NULL,
    Discount DECIMAL(5,2) ,
    TotalPrice DECIMAL(12,2) ,
    
    SalesDate_PART VARCHAR(255),    -- Ab NOT NULL HATA DIYA
    SalesTime_PART VARCHAR(255),    -- Ab NOT NULL HATA DIYA
    
    TransactionNumber VARCHAR(50) NOT NULL UNIQUE,

    FOREIGN KEY (SalesPersonID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
SET FOREIGN_KEY_CHECKS = 1;
