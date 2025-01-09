codeunit 60001 "ARD_Warranty.Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TestCustomerWarranty()
    var
        CustomerRec: Record Customer;
        WarrantyRec: Record ARDWarrantyClaim;
        CustomerCard: TestPage "Customer Card";
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
    begin
        //[Scenario] A customer is assigned a Warranty Claim
        //[Given] A customer record has a Warranty Claim Record associated with it.
        LibrarySales.CreateCustomer(CustomerRec);
        CreateWarrantyClaim(CustomerRec."No.", WarrantyRec);

        //[When] The Customer Card is edited
        CustomerCard.OpenEdit();
        CustomerCard.GoToRecord(CustomerRec);
        
        //[Then] The Warranty Claim is visible and has the desired value
        CustomerCard.ARDCustomerClaims.Expand(true);
        CustomerCard.ARDCustomerClaims.First();
        Assert.IsTrue(CustomerCard.ARDCustomerClaims.Date.Visible(),  'Claim Date should be visible');
        Assert.AreEqual(CustomerCard.ARDCustomerClaims.Details.Value(), WarrantyRec.Details, 'Claim Details should be complete');
    end;

    [Test]
    procedure TestSalesOrder()
    var
        CustomerRec: Record Customer;
        SalesOrderRec: Record "Sales Header";
        SalesLineRec: Record "Sales Line";
        SalesInvoiceRec: Record "Sales Invoice Header";
        SalesOrderCard: TestPage "Sales Order";
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random"; 
        PostedDocNo: Code[20];
    begin
        //[Scenario] A sales order is created
        LibrarySales.CreateCustomer(CustomerRec);

        LibrarySales.CreateSalesHeader(SalesOrderRec, SalesOrderRec."Document Type"::Order, CustomerRec."No."); 
        LibrarySales.CreateSalesLine(SalesLineRec, SalesOrderRec, SalesLineRec.Type::Item, '', 1); 
        SalesLineRec.VALIDATE("Unit Price", LibraryRandom.RandIntInRange(5000, 10000)); 
        SalesLineRec.MODIFY(TRUE); 
        SalesOrderRec.ARD_WarrantyNo := CreateTestWarranty();
        
        //[When] The Sales Order is opened for editing
        SalesOrderCard.OpenEdit();
        SalesOrderCard.GoToRecord(SalesOrderRec);

        //[Then] The warranty values must be visible
        Assert.IsTrue(SalesOrderCard.ARD_WarrantyName.Visible(), 'The Warranty Name should be visible');
        Assert.IsTrue(SalesOrderCard.ARD_WarrantyNo.Visible(), 'The Warranty No should be visible');
        Assert.IsTrue(SalesOrderCard.ARD_WarrantyExpDate.Visible(), 'The Warranty Exp Date should be visible');

        //[When] The sales document is posted
        PostedDocNo := LibrarySales.PostSalesDocument(SalesOrderRec, true, true);
        SalesInvoiceRec.Get(PostedDocNo);

        //[Then] The warranty Exp Date should be populated
        Assert.AreNotEqual(SalesInvoiceRec.ARD_WarrantyExpDate, 0D, 'The Warranty date did not populate');
    end;

    procedure CreateWarrantyClaim(CustomerNo: Code[20]; var WarrantyRec: Record ARDWarrantyClaim)
    begin
        WarrantyRec.Init();
        WarrantyRec."CustomerNo." := CustomerNo;
        WarrantyRec.Details := 'Test';
        WarrantyRec.Date := DT2Date(CurrentDateTime);
        WarrantyRec.Insert();
    end;

    procedure CreateTestWarranty(): Integer
    var
        Warranty: Record ARD_Warranty;
    begin
        Warranty.Init();
        Warranty.ARD_Name := 'Test';
        Warranty.ARD_Description := 'Test for CICD';
        Warranty.Insert();
        exit(Warranty."ARD_No.");
    end;

}
