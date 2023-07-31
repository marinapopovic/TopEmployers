@isTest
public with sharing class TestOrderItemListController {

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

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Order orderRec = new Order();
        orderRec.AccountId = acc.Id;
        orderRec.Status = 'Draft';
        orderRec.EffectiveDate = System.today();
        insert orderRec;
    }
    
    @isTest
    public static void testGetOrderItems() {
        Test.startTest();

        Order ord = [SELECT Id FROM Order LIMIT 1];
        try {
            OrderItemListController.getOrderItems(ord.Id);
        } catch (Exception e) {
        }

        //get order items
        OrderItem item = new OrderItem();
        item.OrderId = ord.Id;
        item.Product2Id = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1].Product2Id;
        item.UnitPrice = 100;
        item.ListPrice = 100;
        item.Quantity = 1;
        insert item;
        List<OrderItem> items = OrderItemListController.getOrderItems(ord.Id);
        Assert.isTrue(!items.isEmpty());

        Test.stopTest();
    }

    @isTest
    public static void testDeleteItem() {
        Test.startTest();

        try {
            OrderItemListController.deleteItem(null);
        } catch (Exception e) {
        }

        //delete items
        Order ord = [SELECT Id FROM Order LIMIT 1];
        OrderItem item = new OrderItem();
        item.OrderId = ord.Id;
        item.Product2Id = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1].Product2Id;
        item.UnitPrice = 100;
        item.ListPrice = 100;
        item.Quantity = 1;
        insert item;
        OrderItemListController.deleteItem(item.Id);
        List<OrderItem> items = [SELECT Id FROM OrderItem WHERE OrderId = :ord.ID];
        Assert.isTrue(items.isEmpty());

        Test.stopTest();
    }

}