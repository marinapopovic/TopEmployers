public with sharing class OrderItemListController {
    
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderItems(String orderId) {
        try {
            List<OrderItem> orderItems = new List<OrderItem>();
            orderItems = [
                SELECT Id, OrderItemNumber, Quantity, Product2.Family,
                    Product2Id, UnitPrice, TotalPrice
                FROM OrderItem
                WHERE OrderId = :orderId
            ];
            return orderItems;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteItem(String itemId) {
        try {
            delete new OrderItem(Id = itemId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}