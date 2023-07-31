public with sharing class ProductListController {

    @AuraEnabled(cacheable = true)
    public static List<PricebookEntry> getActiveProducts() {
        try {
            return [
                SELECT Id, Name, Product2Id, Product2.Name, UnitPrice
                FROM PricebookEntry 
                WHERE IsActive = true AND Pricebook2.IsStandard = true
                LIMIT 100
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void addOrderItem(String orderId, PricebookEntry product) {
        // to do :check if orderId is not null or if record id is not of order
        // to do:if pricebook2Id is not set on order check and update
        try {
            Map<Id, OrderItem> itemMap = new Map<Id, OrderItem>();

            List<OrderItem> items = [
                SELECT Id, Quantity, Product2Id, UnitPrice, TotalPrice
                FROM OrderItem
                WHERE OrderId = :orderId
            ];
            if (!items.isEmpty()) {
                for (OrderItem item : items) {
                    itemMap.put(item.Product2Id, item);
                }
            }

            if (itemMap.containsKey(product.Product2Id)) {
                OrderItem itemForUpdate = itemMap.get(product.Product2Id);
                itemForUpdate.Quantity = itemForUpdate.Quantity + 1;
                update itemForUpdate;
            } else {
                OrderItem newItem = new OrderItem();
                newItem.OrderId = orderId;
                newItem.Product2Id = product.Product2Id;
                newItem.UnitPrice = product.UnitPrice;
                newItem.ListPrice = product.UnitPrice;
                newItem.Quantity = 1;
                insert newItem;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}