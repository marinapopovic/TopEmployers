@isTest
public with sharing class TestProductListController {
    @TestSetup
    static void makeData() {
        //create data
        List<Product2> productList = new List<Product2>();
        for (Integer i = 0; i < 100; i++) {
            Product2 entry = new Product2();
            entry.Name = 'Product' + i;
            entry.IsActive = true;
            productList.add(entry);
        }
        insert productList;

        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;

        List<PricebookEntry> entryList = new List<PricebookEntry>();
        for (Product2 prod : productList) {
            PricebookEntry entry = new PricebookEntry();
            entry.Product2Id = prod.Id;
            entry.Pricebook2Id = standardPricebook.Id;
            entry.UnitPrice = 10;
            entry.IsActive = true;
            entryList.add(entry);
        }
        insert entryList;
    }

    @isTest
    public static void testGetActiveProducts() {
        Test.startTest();
        //get all active product entries
        List<PricebookEntry> entryList = ProductListController.getActiveProducts();
        Assert.isTrue(entryList.size() > 0);
        Test.stopTest();
    }

    @isTest
    public static void testAddOrderItem() {
        Test.startTest();
        try {
            ProductListController.addOrderItem(null, null);
        } catch (Exception e) {
        }
        
        //create account and order
        Account accRec = new Account(Name = 'Test Account');
        insert accRec;
        Order orderRec = new Order();
        orderRec.AccountId = accRec.Id;
        orderRec.Status = 'Draft';
        orderRec.EffectiveDate = System.today();
        insert orderRec;
        PricebookEntry productEntry = [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry LIMIT 1];
        
        //add order item
        ProductListController.addOrderItem(orderRec.Id, productEntry);
        Assert.isFalse(
            [
                SELECT Id
                FROM OrderItem
                WHERE OrderId = :orderRec.Id
            ].isEmpty()
        );

        //add order item with same product to increase quantity
        ProductListController.addOrderItem(orderRec.Id, productEntry);
        Assert.isTrue(
            [
                SELECT Id, Quantity
                FROM OrderItem
                WHERE OrderId = :orderRec.Id
            ].Quantity == 2
        );
        Test.stopTest();
    }

}