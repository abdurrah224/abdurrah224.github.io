/*1.Write a script that declares and sets a variable that’s equal to the count of all rows in the Invoices table that have a
balance due that’s greater than $5,000.00. Then, the script should display a message that looks like this: “2
invoices exceed $5,000.” */
DECLARE @NoOfInvoices INT;
SET @NoOfInvoices = (SELECT COUNT(*) FROM Invoices
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 5000)
PRINT @NoOFInvoices
PRINT ' invocies exceed $5,000.'
PRINT CONVERT(varchar, @NoOfInvoices) + ' invoices exceed $5,000'
GO

/* 2. Write a script that uses variables to get (1) the count of all the invoices in the Invoices table that have a balance due
and (2) the sum of the balances due for all those invoices. If that total balance due is greater than or equal to
$10,000, the script should return a result set consisting of VendorName, InvoiceNumber, InvoiceDueDate, and
Balance for each invoice with a balance due, sorted with the oldest due date first. The script should also display a
message like this:
Number of unpaid invoices is 11.
Total balance due is $32,020.42.
Otherwise, the script should display: “Total balance due is less than $10,000.”
Stored Procedures */
DECLARE @NoOfUnpaidInvoices INT;
DECLARE @TotalBalanceDue MONEY;
SET @NoOfUnpaidInvoices = (
    SELECT COUNT(*)
    FROM Invoices
    WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0
);
SET @TotalBalanceDue = ISNULL((
    SELECT SUM(InvoiceTotal - PaymentTotal - CreditTotal)
    FROM Invoices
    WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0
), 0);
IF @TotalBalanceDue >= 10000
BEGIN
    PRINT 'Number of unpaid invoices is ' + CONVERT(varchar(10), @NoOfUnpaidInvoices) + '.';
    PRINT 'Total balance due is $' + CONVERT(varchar(30), @TotalBalanceDue) + '.';
    SELECT v.VendorName,
           i.InvoiceNumber,
           i.InvoiceDueDate,
           i.InvoiceTotal - i.PaymentTotal - i.CreditTotal AS Balance
    FROM Invoices i
    JOIN Vendors v ON i.VendorID = v.VendorID
    WHERE i.InvoiceTotal - i.PaymentTotal - i.CreditTotal > 0
    ORDER BY i.InvoiceDueDate;
END
ELSE
BEGIN
    PRINT 'Total balance due is less than $10,000.';
END
GO
/*3. Create a stored procedure named spVendorsWithoutInvoices that accepts @VendorName as a required parameter.
The procedure returns a result set consisting of VendorID and VendorName for each vendor that has no invoices,
sorted with VendorName. Call the procedure with vendor names that contain the word ‘service’ or ‘services’. (5
row(s) affected) */
IF OBJECT_ID('spVendorsWithoutInvoices', 'P') IS NOT NULL DROP PROCEDURE spVendorsWithoutInvoices;
GO
CREATE PROCEDURE spVendorsWithoutInvoices
@VendorName NVARCHAR(255)   
AS
BEGIN
    SELECT VendorID, VendorName
    FROM Vendors
    WHERE VendorName LIKE '%' + @VendorName + '%'
      AND VendorID NOT IN (SELECT DISTINCT VendorID FROM Invoices)
    ORDER BY VendorName;
END 
GO
EXEC spVendorsWithoutInvoices @VendorName = 'service'
GO
/*4. Create a stored procedure named spVendorStateInvTotal that accepts @VendorState as an optional parameter and
@SumInvoiceTotal (i.e. the sum of all the invoices) as an output parameter. Then, call the procedure as follows and
print out the value of the output parameter:
a. Without providing @VendorState. (214290.51)
b. With @VendorState = ‘tx’. (2154.42)
c. With @VendorState = ‘t%’. (6532.44) */
IF OBJECT_ID('spVendorStateInvTotal', 'P') IS NOT NULL DROP PROCEDURE spVendorStateInvTotal;
GO
CREATE PROCEDURE spVendorStateInvTotal
@VendorState NVARCHAR(255) = NULL,
@SumInvoiceTotal MONEY OUTPUT
AS
BEGIN
    IF @VendorState IS NULL
    BEGIN
        SELECT @SumInvoiceTotal = SUM(InvoiceTotal)
        FROM Invoices;
    END
    ELSE
    BEGIN
        SELECT @SumInvoiceTotal = SUM(InvoiceTotal)
        FROM Invoices i
        JOIN Vendors v ON i.VendorID = v.VendorID
        WHERE v.VendorState LIKE @VendorState;
    END
END
GO
DECLARE @TotalInvoiceSum MONEY;
EXEC spVendorStateInvTotal @VendorState = NULL, @SumInvoiceTotal = @TotalInvoiceSum OUTPUT;
PRINT 'Total Invoice Sum without VendorState: $' + CONVERT(varchar(30), @TotalInvoiceSum);
EXEC spVendorStateInvTotal @VendorState = 'tx', @SumInvoiceTotal = @TotalInvoiceSum OUTPUT;
PRINT 'Total Invoice Sum for VendorState "tx": $' + CONVERT(varchar(30), @TotalInvoiceSum);
EXEC spVendorStateInvTotal @VendorState = 't%', @SumInvoiceTotal = @TotalInvoiceSum OUTPUT;
PRINT 'Total Invoice Sum for VendorState like "t%": $' + CONVERT(varchar(30), @TotalInvoiceSum);
GO
