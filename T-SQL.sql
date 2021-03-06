USE [Assignment]
--Emir Kovacevic emirkovacevic92@gmail.com UpSkilled Assignment

--1
GO
SELECT * FROM CustDetails
GO

--2
GO
SELECT FName, LName FROM CustDetails
GO

--3
GO
SELECT * FROM CustDetails ORDER BY LName
GO

--4
GO
SELECT * FROM CustDetails WHERE Suburb='Eastway'
GO

--5
GO
SELECT TOP 4 * FROM CustDetails
GO

--6
GO
SELECT LName FROM CustDetails WHERE LName LIKE N'[S-Z]%'
GO

--7
GO
SELECT * FROM CustDetails WHERE suburb LIKE '%east%'
GO

--8
GO
SELECT DISTINCT LName FROM CustDetails
GO

--9
GO
SELECT * FROM CustDetails WHERE Address IS NOT NULL
GO

--10
GO
SELECT SUM(Value) as OrderSum FROM OrderDetails
GO
--I assume all items are delivered, if its not the case than please use query below
GO
SELECT SUM(Value) as OrderSum FROM OrderDetails WHERE DateDelivered IS NOT NULL
GO

--11
GO
SELECT COUNT(OrderRef) AS [Order Count], SUM(Value) AS [Total Value]
 FROM OrderDetails WHERE DATENAME(MONTH, DateOrdered) = 'December'
GO

--12
GO
SELECT * FROM OrderDetails ORDER BY CustRef
GO

--13
GO
SELECT CD.FName, CD.LName, CD.Suburb, OD.Value
FROM CustDetails CD
INNER JOIN OrderDetails OD
ON CD.CustRef = OD.CustRef
WHERE OD.DateDelivered IS NOT NULL ORDER BY Value DESC
GO

--14
--If you need number of orders for each customer:
GO
SELECT c.CustRef, c.LName, C.Fname, COUNT(od.CustRef) OrderdPlaced
FROM CustDetails c
LEFT JOIN OrderDetails od ON od.CustRef =c.CustRef 
GROUP BY c.CustRef ,c.LName, C.Fname
GO

GO
--If you need customer details for each order number:
SELECT CustDetails.FName, CustDetails.LName, OrderDetails.OrderRef [Order Number]
FROM CustDetails
LEFT JOIN OrderDetails ON CustDetails.CustRef = OrderDetails.CustRef
GO

--15
GO
SELECT *
FROM CustDetails
WHERE Suburb IN
	(SELECT Suburb
	 FROM CustDetails
	 WHERE LName !='Stevens')
GO

--16
GO
CREATE TABLE StaffDetails (
    StaffRef int NOT NULL PRIMARY KEY,
    LName nchar(25) NOT NULL,
    FName nchar(25) NOT NULL,
    Phone nchar(25),
    StartDate date NOT NULL
);
GO

--17
GO
INSERT INTO StaffDetails
VALUES('52','Jacobs','John','','2/11/2009')
GO

--18
GO
UPDATE OrderDetails
SET DateOrdered = '2009-12-1'
WHERE OrderRef = 4
GO

--19
GO
ALTER TABLE StaffDetails ADD Email nchar(50);
GO

--20
GO
DELETE FROM OrderDetails WHERE OrderRef = 9
GO

--21
GO
CREATE VIEW Contacts
AS
(
SELECT        LName, FName, Phone
FROM            dbo.StaffDetails
)
GO

--22
GO
DROP VIEW Contacts
GO

--23
GO
CREATE PROCEDURE AddOrder
	@OrderReference nchar(25),
	@CustomerReference nchar(25),
	@DateOrdered date,
	@Value nchar(25),
	@DateDelivered date

AS

SET IDENTITY_INSERT OrderDetails ON 
INSERT INTO OrderDetails
(
OrderRef,
CustRef,
DateOrdered,
Value,
DateDelivered
)
VALUES
(
@OrderReference,
@CustomerReference,
@DateOrdered,
@Value,
@DateDelivered
)

SET IDENTITY_INSERT OrderDetails OFF

--EXEC AddOrder
--@OrderReference = '10',
--@CustomerReference = '4',
--@DateOrdered = '20091216',
--@Value = '$2320.40',
--@DateDelivered = NULL
GO

--24
GO
CREATE PROCEDURE spCancelOrder
	@OrderRef nchar(25)
AS
DELETE FROM OrderDetails WHERE OrderRef = @OrderRef

EXEC spCancelOrder 10
GO

--25
GO
CREATE TRIGGER TblUpdated
ON OrderDetails
after insert
as
begin
	RAISERROR('OrderDetails table has been updated',0,-10);
end
GO

--26
GO
Declare @errorMessage nvarchar(500);
declare @isError bit = 0;

begin try
select 1/0;
end try

begin catch
select @isError = 1
 , @errorMessage = ERROR_MESSAGE();
end catch

if @isError = 1
begin
  RAISERROR (@errorMessage, 16, 1);
end
GO

--27
GO
Create procedure [spAddPercentage] 
@incPercent money  
as
update OrderDetails 
set @incPercent = '*1.1'

if exists (select * from OrderDetails where Value < @incPercent  *  1.1) 

select * from  orderdetails where Value > @incpercent * 1.1
else
select * from OrderDetails where value = @incpercent * 1.1
GO

--28
GO
CREATE PROCEDURE spCustomerValue
	@CustomerRef nchar(25)
AS
SELECT SUM(Value) FROM OrderDetails WHERE CustRef = @CustomerRef

EXECUTE spCustomerValue 9
GO

--29
GO
create trigger ValidOrder
on dbo.orderdetails

 for insert, update
 as
 declare @value int
 select @value = floor(Value)
 
 from orderdetails
 
begin  

if (@value < 100 )
rollback
end
GO