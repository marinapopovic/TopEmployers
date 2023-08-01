import { LightningElement, wire } from 'lwc';
import getOrderItems from '@salesforce/apex/OrderItemListController.getOrderItems';
import deleteItem from '@salesforce/apex/OrderItemListController.deleteItem';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
import topChannel from '@salesforce/messageChannel/TopMessageChannel__c';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ORDER_TOTAL from '@salesforce/schema/Order.TotalAmount';
import { CurrentPageReference } from 'lightning/navigation';

export default class OrderItemList extends LightningElement {
    actions = [{ label: 'Delete', name: 'delete' }];
    orderItemColumns = [
        { label: 'Name', fieldName: 'OrderItemNumber', type: 'text' },
        { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency' },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number' },
        { label: 'Total Price', fieldName:'TotalPrice', type: 'currency' },
        {
            type: 'action',
            typeAttributes: { rowActions: this.actions }
        }
    ];
    subscription = null;
    recordId = '';
    error = '';

    @wire(MessageContext) messageContext;
    @wire(CurrentPageReference) setParamethers(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state?.c__recordId;
        }
    }
    @wire(getOrderItems, {orderId: '$recordId'}) orderItems;
    @wire(getRecord, {recordId : '$recordId', fields: [ORDER_TOTAL]}) order;
    
    get orderTotal() {
        return getFieldValue(this.order.data, ORDER_TOTAL);
    }
    
    get calculatedSubtotals() {
        let familyOrderItemMap = new Map();
        this.orderItems.data.forEach(element => {
            let family = element.Product2.Family;
            if (family === '' || family === undefined) {
                family = 'None';
            }
            
            if (familyOrderItemMap.has(family)) {
                let totalAmount = familyOrderItemMap.get(family).TotalPrice + element.TotalPrice;
                let familyItem = { 'Name' : family, 'TotalPrice' : totalAmount};
                familyOrderItemMap.set(family, familyItem);
            } else {
                let familyItem = { 'Name' : family, 'TotalPrice' : element.TotalPrice};
                familyOrderItemMap.set(family, familyItem);
            }
        });
        // to do : check
        return Array.from(familyOrderItemMap.values());  
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.delete(row);
                break;
        }
    }

    delete(row) {
        deleteItem({itemId : row.Id})
        .then(() => {
            this.refreshVariables();
        })
        .catch(error => {
            this.error = error;
        });
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    refreshVariables() {
        refreshApex(this.orderItems);
        refreshApex(this.order);
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                topChannel,
                () => this.refreshVariables(),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    
}