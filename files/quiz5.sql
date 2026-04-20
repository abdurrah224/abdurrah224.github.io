/* QUIZ 5 */

/* Create a view named VendorAddress that returns the VendorID, both address columns, and the city, state, and zip
code columns for each vendor. Use the WITH SCHEMABINDING option. */
IF OBJECT_ID('VendorAddress') IS NOT NULL DROP VIEW VendorAddress
GO
CREATE VIEW VendorAddress WITH SCHEMABINDING AS
SELECT VendorID, VendorAddress1, VendorAddress2, VendorCity, VendorState, VendorZipCode
FROM dbo.Vendors
GO
/* 2. Then, write a SELECT query to examine the result set of the VendorAddress view where VendorID=4. (1 row(s)affected) */
SELECT * FROM VendorAddress WHERE VendorID = 4
/* 3. Create a view named InvoiceBasic that returns InvoiceNumber and InvoiceTotal. Then, write a SELECT statement
that returns all of the columns in the view, sorted by InvoiceTotal in descending order. (114 row(s) affected) */
IF OBJECT_ID('InvoiceBasic') IS NOT NULL DROP VIEW InvoiceBasic
GO
CREATE VIEW InvoiceBasic AS
SELECT InvoiceNumber, InvoiceTotal FROM dbo.Invoices
GO
SELECT * FROM InvoiceBasic 
ORDER BY InvoiceTotal DESC

/* 4. Create a view named VendorInvoice that returns VendorName, InvoiceNumber, and InvoiceTotal. Then, write a
SELECT statement that returns all of the columns in the view, sorted by VendorName, where the first letter of the
vendor name is A, N, O, or P. (9 row(s) affected) */
IF OBJECT_ID('VendorInvoice') IS NOT NULL DROP VIEW VendorInvoice
GO
CREATE VIEW VendorInvoice AS
SELECT VendorName, InvoiceNumber, InvoiceTotal
FROM dbo.Vendors v JOIN dbo.Invoices i ON v.VendorID = i.VendorID
GO
SELECT * FROM VendorInvoice 
WHERE LEFT(VendorName, 1) IN ('A', 'N', 'O', 'P')
ORDER BY VendorName
GO
/* 5. Modify the view in #4 using ALTER VIEW statement to return VendorName, InvoiceNumber, InvoiceTotal, and
TermsDescription. Then, write a SELECT statement that returns all of the columns in the view, sorted by
VendorName, where the first letter of the vendor name is A, N, O, or P and the term description is ‘Net due 10 days’.
(1 row(s) affected) */
ALTER VIEW VendorInvoice AS
SELECT VendorName, InvoiceNumber, InvoiceTotal, TermsDescription
FROM dbo.Vendors v 
JOIN dbo.Invoices i ON v.VendorID = i.VendorID
JOIN dbo.Terms t ON i.TermsID = t.TermsID
GO
/* 6. Modify the view in #4 using ALTER VIEW statement to return VendorName, InvoiceNumber, InvoiceTotal,
TermsDescription, and (InvoiceTotal – PaymentTotal – CreditTotal). Then, write a SELECT statement that returns all
of the columns in the view, sorted by VendorName, where the first letter of the vendor name is A, N, O, or P and the
term description is ‘Net due 10 days’. (1 row(s) affected) */
ALTER VIEW VendorInvoice AS
SELECT VendorName, InvoiceNumber, InvoiceTotal, TermsDescription, (InvoiceTotal - PaymentTotal - CreditTotal) AS Balance
FROM dbo.Vendors v 
JOIN dbo.Invoices i ON v.VendorID = i.VendorID
JOIN dbo.Terms t ON i.TermsID = t.TermsID
GO
SELECT * FROM VendorInvoice 
WHERE LEFT(VendorName, 1) IN ('A', 'N', 'O', 'P') AND TermsDescription = 'Net due 10 days'
ORDER BY VendorName
GO  

/* 7. Create a view named InvoiceTotalPlus10% that returns the following three columns: InvoiceTotal, 10% of the value
of InvoiceTotal, and the value of Invoicetotal plus the 10%. Ensure that the user cannot see the code that defines the
view. Then, write a SELECT statement that returns all the columns in the view, sorted by the value of Invoicetotal
plus the 10% in descending order. (114 row(s) affected) */
IF OBJECT_ID('InvoiceTotalPlus10Percent') IS NOT NULL DROP VIEW InvoiceTotalPlus10Percent
GO
CREATE VIEW InvoiceTotalPlus10Percent WITH ENCRYPTION AS
SELECT InvoiceTotal, InvoiceTotal * 0.1 AS TenPercent, InvoiceTotal * 1.1 AS TotalPlusTenPercent
FROM dbo.Invoices
GO
SELECT * FROM InvoiceTotalPlus10Percent
ORDER BY TotalPlusTenPercent DESC
GO
/* 8. Create a view named InvoicePerVendor that returns VendorName, the quantity of invoices, and the total of invoices
of all the vendors, including those without any invoices. Then, write a SELECT statement that returns all of the
columns in the view, sorted by the quantity of invoices in ascending order. (122 row(s) affected) */
IF OBJECT_ID('InvoicePerVendor') IS NOT NULL DROP VIEW InvoicePerVendor
GO
CREATE VIEW InvoicePerVendor AS
SELECT v.VendorName, COUNT(i.InvoiceID) AS InvoiceCount, SUM(i.InvoiceTotal) AS TotalInvoice
FROM dbo.Vendors v
LEFT JOIN dbo.Invoices i ON v.VendorID = i.VendorID
GROUP BY v.VendorName
GO
SELECT * FROM InvoicePerVendor
ORDER BY InvoiceCount ASC
GO
/* 9. Create a view named Top10PaidInvoices that returns three columns for each vendor: VendorName, LastInvoice (the
most recent invoice date), and SumOfInvoices (the sum of the InvoiceTotal column). Return only the 10 vendors with
the largest SumOfInvoices and include only paid invoices. Then, write a SELECT statement that returns all of the
columns in the view. (10 row(s) affected) */
IF OBJECT_ID('Top10PaidInvoices') IS NOT NULL DROP VIEW Top10PaidInvoices
GO
CREATE VIEW Top10PaidInvoices AS
SELECT TOP 10 v.VendorName, MAX(i.InvoiceDate) AS LastInvoice, SUM(i.InvoiceTotal) AS SumOfInvoices
FROM dbo.Vendors v
LEFT JOIN dbo.Invoices i ON v.VendorID = i.VendorID
WHERE i.PaymentDate IS NOT NULL
GROUP BY v.VendorName
ORDER BY SumOfInvoices DESC
GO
SELECT * FROM Top10PaidInvoices
GO