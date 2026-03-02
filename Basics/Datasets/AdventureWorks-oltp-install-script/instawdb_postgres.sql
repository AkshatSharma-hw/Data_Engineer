-- Active: 1772031412894@@127.0.0.1@5432@adventureworks
/*
PostgreSQL version of the AdventureWorks database schema and data loading.

** HOW TO RUN THIS SCRIPT **

1. From your terminal, create the database first by running:
   `createdb AdventureWorks`

2. Then, connect to the database and run this script. You can do this in one command:
   `psql -d AdventureWorks -f instawdb_postgres.sql`

   Note: This script assumes the CSV files are in the same directory where you run the `psql` command.
*/

-- Drop existing schemas and tables to make the script idempotent.
DROP SCHEMA IF EXISTS HumanResources CASCADE;
DROP SCHEMA IF EXISTS Person CASCADE;
DROP SCHEMA IF EXISTS Production CASCADE;
DROP SCHEMA IF EXISTS Purchasing CASCADE;
DROP SCHEMA IF EXISTS Sales CASCADE;
DROP TABLE IF EXISTS public.AWBuildVersion;
DROP TABLE IF EXISTS public.ErrorLog;
DROP TABLE IF EXISTS public.DatabaseLog;

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create schemas
CREATE SCHEMA HumanResources;
CREATE SCHEMA Person;
CREATE SCHEMA Production;
CREATE SCHEMA Purchasing;
CREATE SCHEMA Sales;

-- Create custom types (domains) for SQL Server user-defined types
CREATE DOMAIN public.AccountNumber AS VARCHAR(15);
CREATE DOMAIN public.Flag AS BOOLEAN;
CREATE DOMAIN public.Name AS VARCHAR(50);
CREATE DOMAIN public.NameStyle AS BOOLEAN;
CREATE DOMAIN public.OrderNumber AS VARCHAR(25);
CREATE DOMAIN public.Phone AS VARCHAR(25);


-- Create Tables

CREATE TABLE public.AWBuildVersion(
    SystemInformationID SERIAL PRIMARY KEY,
    "Database Version" VARCHAR(25) NOT NULL,
    VersionDate TIMESTAMP NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Person.Address(
    AddressID INT NOT NULL,
    AddressLine1 VARCHAR(60) NOT NULL,
    AddressLine2 VARCHAR(60) NULL,
    City VARCHAR(30) NOT NULL,
    StateProvinceID INT NOT NULL,
    PostalCode VARCHAR(15) NOT NULL,
    SpatialLocation TEXT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Person.AddressType(
    AddressTypeID INT NOT NULL,
    Name public.Name NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.BillOfMaterials(
    BillOfMaterialsID INT NOT NULL,
    ProductAssemblyID INT NULL,
    ComponentID INT NOT NULL,
    StartDate TIMESTAMP NOT NULL,
    EndDate TIMESTAMP NULL,
    UnitMeasureCode CHAR(3) NOT NULL,
    BOMLevel SMALLINT NOT NULL,
    PerAssemblyQty NUMERIC(8, 2) NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Person.BusinessEntity(
    BusinessEntityID INT NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Person.BusinessEntityAddress(
    BusinessEntityID INT NOT NULL,
    AddressID INT NOT NULL,
    AddressTypeID INT NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Person.BusinessEntityContact(
    BusinessEntityID INT NOT NULL,
    PersonID INT NOT NULL,
    ContactTypeID INT NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Person.ContactType(
    ContactTypeID INT NOT NULL,
    Name public.Name NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Person.CountryRegion(
    CountryRegionCode VARCHAR(3) NOT NULL,
    Name public.Name NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.CountryRegionCurrency(
    CountryRegionCode VARCHAR(3) NOT NULL,
    CurrencyCode CHAR(3) NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.CreditCard(
    CreditCardID INT NOT NULL,
    CardType VARCHAR(50) NOT NULL,
    CardNumber VARCHAR(25) NOT NULL,
    ExpMonth SMALLINT NOT NULL,
    ExpYear SMALLINT NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.Culture(
    CultureID CHAR(6) NOT NULL,
    Name public.Name NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.Currency(
    CurrencyCode CHAR(3) NOT NULL,
    Name public.Name NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.CurrencyRate(
    CurrencyRateID INT NOT NULL,
    CurrencyRateDate TIMESTAMP NOT NULL,
    FromCurrencyCode CHAR(3) NOT NULL,
    ToCurrencyCode CHAR(3) NOT NULL,
    AverageRate NUMERIC(19, 4) NOT NULL,
    EndOfDayRate NUMERIC(19, 4) NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.Customer(
    CustomerID INT NOT NULL,
    PersonID INT NULL,
    StoreID INT NULL,
    TerritoryID INT NULL,
    AccountNumber VARCHAR(10) GENERATED ALWAYS AS ('AW' || LPAD(CustomerID::text, 8, '0')) STORED,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE HumanResources.Department(
    DepartmentID SMALLINT NOT NULL,
    Name public.Name NOT NULL,
    GroupName public.Name NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Person.EmailAddress(
    BusinessEntityID INT NOT NULL,
    EmailAddressID INT NOT NULL,
    EmailAddress VARCHAR(50) NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE HumanResources.Employee(
    BusinessEntityID INT NOT NULL,
    NationalIDNumber VARCHAR(15) NOT NULL,
    LoginID VARCHAR(256) NOT NULL,
    OrganizationNode VARCHAR(256),
    OrganizationLevel SMALLINT,
    JobTitle VARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    MaritalStatus CHAR(1) NOT NULL,
    Gender CHAR(1) NOT NULL,
    HireDate DATE NOT NULL,
    SalariedFlag public.Flag NOT NULL,
    VacationHours SMALLINT NOT NULL,
    SickLeaveHours SMALLINT NOT NULL,
    CurrentFlag public.Flag NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE HumanResources.EmployeeDepartmentHistory(
    BusinessEntityID INT NOT NULL,
    DepartmentID SMALLINT NOT NULL,
    ShiftID SMALLINT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE HumanResources.EmployeePayHistory(
    BusinessEntityID INT NOT NULL,
    RateChangeDate TIMESTAMP NOT NULL,
    Rate NUMERIC(19, 4) NOT NULL,
    PayFrequency SMALLINT NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.Illustration(
    IllustrationID INT NOT NULL,
    Diagram XML NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE HumanResources.JobCandidate(
    JobCandidateID INT NOT NULL,
    BusinessEntityID INT NULL,
    Resume XML NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.Location(
    LocationID SMALLINT NOT NULL,
    Name public.Name NOT NULL,
    CostRate NUMERIC(10, 4) NOT NULL,
    Availability NUMERIC(8, 2) NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Person.Password(
    BusinessEntityID INT NOT NULL,
    PasswordHash VARCHAR(128) NOT NULL,
    PasswordSalt VARCHAR(10) NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Person.Person(
    BusinessEntityID INT NOT NULL,
    PersonType CHAR(2) NOT NULL,
    NameStyle public.NameStyle NOT NULL,
    Title VARCHAR(8) NULL,
    FirstName public.Name NOT NULL,
    MiddleName public.Name NULL,
    LastName public.Name NOT NULL,
    Suffix VARCHAR(10) NULL,
    EmailPromotion INT NOT NULL,
    AdditionalContactInfo XML NULL,
    Demographics XML NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.PersonCreditCard(
    BusinessEntityID INT NOT NULL,
    CreditCardID INT NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Person.PersonPhone(
    BusinessEntityID INT NOT NULL,
    PhoneNumber public.Phone NOT NULL,
    PhoneNumberTypeID INT NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Person.PhoneNumberType(
    PhoneNumberTypeID INT NOT NULL,
    Name public.Name NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.Product(
    ProductID INT NOT NULL,
    Name public.Name NOT NULL,
    ProductNumber VARCHAR(25) NOT NULL,
    MakeFlag public.Flag NOT NULL,
    FinishedGoodsFlag public.Flag NOT NULL,
    Color VARCHAR(15) NULL,
    SafetyStockLevel SMALLINT NOT NULL,
    ReorderPoint SMALLINT NOT NULL,
    StandardCost NUMERIC(19, 4) NOT NULL,
    ListPrice NUMERIC(19, 4) NOT NULL,
    Size VARCHAR(5) NULL,
    SizeUnitMeasureCode CHAR(3) NULL,
    WeightUnitMeasureCode CHAR(3) NULL,
    Weight NUMERIC(8, 2) NULL,
    DaysToManufacture INT NOT NULL,
    ProductLine CHAR(2) NULL,
    Class CHAR(2) NULL,
    Style CHAR(2) NULL,
    ProductSubcategoryID INT NULL,
    ProductModelID INT NULL,
    SellStartDate TIMESTAMP NOT NULL,
    SellEndDate TIMESTAMP NULL,
    DiscontinuedDate TIMESTAMP NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductCategory(
    ProductCategoryID INT NOT NULL,
    Name public.Name NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductCostHistory(
    ProductID INT NOT NULL,
    StartDate TIMESTAMP NOT NULL,
    EndDate TIMESTAMP NULL,
    StandardCost NUMERIC(19, 4) NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductDescription(
    ProductDescriptionID INT NOT NULL,
    Description VARCHAR(400) NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductDocument(
    ProductID INT NOT NULL,
    DocumentNode VARCHAR(256) NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductInventory(
    ProductID INT NOT NULL,
    LocationID SMALLINT NOT NULL,
    Shelf VARCHAR(10) NOT NULL,
    Bin SMALLINT NOT NULL,
    Quantity SMALLINT NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductListPriceHistory(
    ProductID INT NOT NULL,
    StartDate TIMESTAMP NOT NULL,
    EndDate TIMESTAMP NULL,
    ListPrice NUMERIC(19, 4) NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductModel(
    ProductModelID INT NOT NULL,
    Name public.Name NOT NULL,
    CatalogDescription XML NULL,
    Instructions XML NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductModelIllustration(
    ProductModelID INT NOT NULL,
    IllustrationID INT NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductModelProductDescriptionCulture(
    ProductModelID INT NOT NULL,
    ProductDescriptionID INT NOT NULL,
    CultureID CHAR(6) NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductPhoto(
    ProductPhotoID INT NOT NULL,
    ThumbNailPhoto BYTEA NULL,
    ThumbnailPhotoFileName VARCHAR(50) NULL,
    LargePhoto BYTEA NULL,
    LargePhotoFileName VARCHAR(50) NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductProductPhoto(
    ProductID INT NOT NULL,
    ProductPhotoID INT NOT NULL,
    "Primary" public.Flag NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductReview(
    ProductReviewID INT NOT NULL,
    ProductID INT NOT NULL,
    ReviewerName public.Name NOT NULL,
    ReviewDate TIMESTAMP NOT NULL,
    EmailAddress VARCHAR(50) NOT NULL,
    Rating INT NOT NULL,
    Comments VARCHAR(3850),
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ProductSubcategory(
    ProductSubcategoryID INT NOT NULL,
    ProductCategoryID INT NOT NULL,
    Name public.Name NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Purchasing.ProductVendor(
    ProductID INT NOT NULL,
    BusinessEntityID INT NOT NULL,
    AverageLeadTime INT NOT NULL,
    StandardPrice NUMERIC(19, 4) NOT NULL,
    LastReceiptCost NUMERIC(19, 4) NULL,
    LastReceiptDate TIMESTAMP NULL,
    MinOrderQty INT NOT NULL,
    MaxOrderQty INT NOT NULL,
    OnOrderQty INT NULL,
    UnitMeasureCode CHAR(3) NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Purchasing.PurchaseOrderDetail(
    PurchaseOrderID INT NOT NULL,
    PurchaseOrderDetailID INT NOT NULL,
    DueDate TIMESTAMP NOT NULL,
    OrderQty SMALLINT NOT NULL,
    ProductID INT NOT NULL,
    UnitPrice NUMERIC(19, 4) NOT NULL,
    LineTotal NUMERIC(19, 4),
    ReceivedQty NUMERIC(8, 2) NOT NULL,
    RejectedQty NUMERIC(8, 2) NOT NULL,
    StockedQty NUMERIC(9, 2),
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Purchasing.PurchaseOrderHeader(
    PurchaseOrderID INT NOT NULL,
    RevisionNumber SMALLINT NOT NULL,
    Status SMALLINT NOT NULL,
    EmployeeID INT NOT NULL,
    VendorID INT NOT NULL,
    ShipMethodID INT NOT NULL,
    OrderDate TIMESTAMP NOT NULL,
    ShipDate TIMESTAMP NULL,
    SubTotal NUMERIC(19, 4) NOT NULL,
    TaxAmt NUMERIC(19, 4) NOT NULL,
    Freight NUMERIC(19, 4) NOT NULL,
    TotalDue NUMERIC(19, 4),
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.SalesOrderDetail(
    SalesOrderID INT NOT NULL,
    SalesOrderDetailID INT NOT NULL,
    CarrierTrackingNumber VARCHAR(25) NULL,
    OrderQty SMALLINT NOT NULL,
    ProductID INT NOT NULL,
    SpecialOfferID INT NOT NULL,
    UnitPrice NUMERIC(19, 4) NOT NULL,
    UnitPriceDiscount NUMERIC(19, 4) NOT NULL,
    LineTotal NUMERIC(38, 6),
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.SalesOrderHeader(
    SalesOrderID INT NOT NULL,
    RevisionNumber SMALLINT NOT NULL,
    OrderDate TIMESTAMP NOT NULL,
    DueDate TIMESTAMP NOT NULL,
    ShipDate TIMESTAMP NULL,
    Status SMALLINT NOT NULL,
    OnlineOrderFlag public.Flag NOT NULL,
    SalesOrderNumber VARCHAR(25),
    PurchaseOrderNumber public.OrderNumber NULL,
    AccountNumber public.AccountNumber NULL,
    CustomerID INT NOT NULL,
    SalesPersonID INT NULL,
    TerritoryID INT NULL,
    BillToAddressID INT NOT NULL,
    ShipToAddressID INT NOT NULL,
    ShipMethodID INT NOT NULL,
    CreditCardID INT NULL,
    CreditCardApprovalCode VARCHAR(15) NULL,
    CurrencyRateID INT NULL,
    SubTotal NUMERIC(19, 4) NOT NULL,
    TaxAmt NUMERIC(19, 4) NOT NULL,
    Freight NUMERIC(19, 4) NOT NULL,
    TotalDue NUMERIC(19, 4),
    Comment VARCHAR(128) NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.SalesOrderHeaderSalesReason(
    SalesOrderID INT NOT NULL,
    SalesReasonID INT NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.SalesPerson(
    BusinessEntityID INT NOT NULL,
    TerritoryID INT NULL,
    SalesQuota NUMERIC(19, 4) NULL,
    Bonus NUMERIC(19, 4) NOT NULL,
    CommissionPct NUMERIC(10, 4) NOT NULL,
    SalesYTD NUMERIC(19, 4) NOT NULL,
    SalesLastYear NUMERIC(19, 4) NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.SalesPersonQuotaHistory(
    BusinessEntityID INT NOT NULL,
    QuotaDate TIMESTAMP NOT NULL,
    SalesQuota NUMERIC(19, 4) NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.SalesReason(
    SalesReasonID INT NOT NULL,
    Name public.Name NOT NULL,
    ReasonType public.Name NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.SalesTaxRate(
    SalesTaxRateID INT NOT NULL,
    StateProvinceID INT NOT NULL,
    TaxType SMALLINT NOT NULL,
    TaxRate NUMERIC(10, 4) NOT NULL,
    Name public.Name NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.SalesTerritory(
    TerritoryID INT NOT NULL,
    Name public.Name NOT NULL,
    CountryRegionCode VARCHAR(3) NOT NULL,
    "Group" VARCHAR(50) NOT NULL,
    SalesYTD NUMERIC(19, 4) NOT NULL,
    SalesLastYear NUMERIC(19, 4) NOT NULL,
    CostYTD NUMERIC(19, 4) NOT NULL,
    CostLastYear NUMERIC(19, 4) NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.SalesTerritoryHistory(
    BusinessEntityID INT NOT NULL,
    TerritoryID INT NOT NULL,
    StartDate TIMESTAMP NOT NULL,
    EndDate TIMESTAMP NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.ScrapReason(
    ScrapReasonID SMALLINT NOT NULL,
    Name public.Name NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE HumanResources.Shift(
    ShiftID SMALLINT NOT NULL,
    Name public.Name NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Purchasing.ShipMethod(
    ShipMethodID INT NOT NULL,
    Name public.Name NOT NULL,
    ShipBase NUMERIC(19, 4) NOT NULL,
    ShipRate NUMERIC(19, 4) NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.ShoppingCartItem(
    ShoppingCartItemID INT NOT NULL,
    ShoppingCartID VARCHAR(50) NOT NULL,
    Quantity INT NOT NULL,
    ProductID INT NOT NULL,
    DateCreated TIMESTAMP NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.SpecialOffer(
    SpecialOfferID INT NOT NULL,
    Description VARCHAR(255) NOT NULL,
    DiscountPct NUMERIC(10, 4) NOT NULL,
    Type VARCHAR(50) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    StartDate TIMESTAMP NOT NULL,
    EndDate TIMESTAMP NOT NULL,
    MinQty INT NOT NULL,
    MaxQty INT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.SpecialOfferProduct(
    SpecialOfferID INT NOT NULL,
    ProductID INT NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Person.StateProvince(
    StateProvinceID INT NOT NULL,
    StateProvinceCode CHAR(3) NOT NULL,
    CountryRegionCode VARCHAR(3) NOT NULL,
    IsOnlyStateProvinceFlag public.Flag NOT NULL,
    Name public.Name NOT NULL,
    TerritoryID INT NOT NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Sales.Store(
    BusinessEntityID INT NOT NULL,
    Name public.Name NOT NULL,
    SalesPersonID INT NULL,
    Demographics XML NULL,
    rowguid UUID NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.TransactionHistory(
    TransactionID INT NOT NULL,
    ProductID INT NOT NULL,
    ReferenceOrderID INT NOT NULL,
    ReferenceOrderLineID INT NOT NULL,
    TransactionDate TIMESTAMP NOT NULL,
    TransactionType CHAR(1) NOT NULL,
    Quantity INT NOT NULL,
    ActualCost NUMERIC(19, 4) NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.TransactionHistoryArchive(
    TransactionID INT NOT NULL,
    ProductID INT NOT NULL,
    ReferenceOrderID INT NOT NULL,
    ReferenceOrderLineID INT NOT NULL,
    TransactionDate TIMESTAMP NOT NULL,
    TransactionType CHAR(1) NOT NULL,
    Quantity INT NOT NULL,
    ActualCost NUMERIC(19, 4) NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.UnitMeasure(
    UnitMeasureCode CHAR(3) NOT NULL,
    Name public.Name NOT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Purchasing.Vendor(
    BusinessEntityID INT NOT NULL,
    AccountNumber public.AccountNumber NOT NULL,
    Name public.Name NOT NULL,
    CreditRating SMALLINT NOT NULL,
    PreferredVendorStatus public.Flag NOT NULL,
    ActiveFlag public.Flag NOT NULL,
    PurchasingWebServiceURL VARCHAR(1024) NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.WorkOrder(
    WorkOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    OrderQty INT NOT NULL,
    StockedQty INT,
    ScrappedQty SMALLINT NOT NULL,
    StartDate TIMESTAMP NOT NULL,
    EndDate TIMESTAMP NULL,
    DueDate TIMESTAMP NOT NULL,
    ScrapReasonID SMALLINT NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

CREATE TABLE Production.WorkOrderRouting(
    WorkOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    OperationSequence SMALLINT NOT NULL,
    LocationID SMALLINT NOT NULL,
    ScheduledStartDate TIMESTAMP NOT NULL,
    ScheduledEndDate TIMESTAMP NOT NULL,
    ActualStartDate TIMESTAMP NULL,
    ActualEndDate TIMESTAMP NULL,
    ActualResourceHrs NUMERIC(9, 4) NULL,
    PlannedCost NUMERIC(19, 4) NOT NULL,
    ActualCost NUMERIC(19, 4) NULL,
    ModifiedDate TIMESTAMP NOT NULL
);

-- Data Loading

-- Note: The paths to the CSV files are relative to where the psql command is run.
-- You might need to adjust the paths or run psql from the directory containing the CSVs.
-- For simplicity, this script assumes the CSV files are in the same directory.

COPY Person.Address FROM 'Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Address.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Person.AddressType FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/AddressType.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.BillOfMaterials FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/BillOfMaterials.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Person.BusinessEntity FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/BusinessEntity.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Person.BusinessEntityAddress FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/BusinessEntityAddress.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Person.BusinessEntityContact FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/BusinessEntityContact.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Person.ContactType FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ContactType.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Person.CountryRegion FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/CountryRegion.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.CountryRegionCurrency FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/CountryRegionCurrency.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.CreditCard FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/CreditCard.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.Culture FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Culture.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.Currency FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Currency.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.CurrencyRate FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/CurrencyRate.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.Customer FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Customer.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY HumanResources.Department FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Department.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Person.EmailAddress FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/EmailAddress.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY HumanResources.Employee FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Employee.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY HumanResources.EmployeeDepartmentHistory FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/EmployeeDepartmentHistory.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY HumanResources.EmployeePayHistory FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/EmployeePayHistory.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.Illustration FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Illustration.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY HumanResources.JobCandidate FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/JobCandidate.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.Location FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Location.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Person.Password FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Password.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Person.Person FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Person.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.PersonCreditCard FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/PersonCreditCard.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Person.PersonPhone FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/PersonPhone.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Person.PhoneNumberType FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/PhoneNumberType.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.Product FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Product.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductCategory FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductCategory.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductCostHistory FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductCostHistory.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductDescription FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductDescription.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductDocument FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductDocument.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductInventory FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductInventory.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductListPriceHistory FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductListPriceHistory.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductModel FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductModel.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductModelIllustration FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductModelIllustration.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductModelProductDescriptionCulture FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductModelProductDescriptionCulture.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductPhoto FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductPhoto.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductProductPhoto FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductProductPhoto.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductReview FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductReview.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ProductSubcategory FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductSubcategory.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Purchasing.ProductVendor FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ProductVendor.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Purchasing.PurchaseOrderDetail FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/PurchaseOrderDetail.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Purchasing.PurchaseOrderHeader FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/PurchaseOrderHeader.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.SalesOrderDetail FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/SalesOrderDetail.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.SalesOrderHeader FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/SalesOrderHeader.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.SalesOrderHeaderSalesReason FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/SalesOrderHeaderSalesReason.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.SalesPerson FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/SalesPerson.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.SalesPersonQuotaHistory FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/SalesPersonQuotaHistory.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.SalesReason FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/SalesReason.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.SalesTaxRate FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/SalesTaxRate.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.SalesTerritory FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/SalesTerritory.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.SalesTerritoryHistory FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/SalesTerritoryHistory.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.ScrapReason FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ScrapReason.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY HumanResources.Shift FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Shift.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Purchasing.ShipMethod FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ShipMethod.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.ShoppingCartItem FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/ShoppingCartItem.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.SpecialOffer FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/SpecialOffer.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.SpecialOfferProduct FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/SpecialOfferProduct.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Person.StateProvince FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/StateProvince.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Sales.Store FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Store.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.TransactionHistory FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/TransactionHistory.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.TransactionHistoryArchive FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/TransactionHistoryArchive.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.UnitMeasure FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/UnitMeasure.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Purchasing.Vendor FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/Vendor.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.WorkOrder FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/WorkOrder.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
COPY Production.WorkOrderRouting FROM '/Users/vidushirawat/Downloads/Akshat/Code/Data_Engineering/Data_Engineer/Basics/Datasets/AdventureWorks-oltp-install-script/WorkOrderRouting.csv' WITH (FORMAT csv, HEADER, DELIMITER E'	');
