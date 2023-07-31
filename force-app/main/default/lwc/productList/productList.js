import { LightningElement, wire, api } from 'lwc';
import getProducts from '@salesforce/apex/ProductListController.getActiveProducts';
import addOrderItem from '@salesforce/apex/ProductListController.addOrderItem';
import { publish, MessageContext } from 'lightning/messageService';
import topChannel from '@salesforce/messageChannel/TopMessageChannel__c';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProductList extends LightningElement {
    actions = [
        { label: 'Add to order', name: 'add_to_order' }
    ];
    prodColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'List Price', fieldName: 'UnitPrice', type: 'currency' },
        {
            type: 'action',
            typeAttributes: { rowActions: this.actions }
        }
    ];
    recordId = '';

    @wire(MessageContext) messageContext;
    @wire(CurrentPageReference) setParamethers(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state?.c__recordId;
        }
    }
    @wire(getProducts) products;

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'add_to_order':
                this.add(row);
                break;
        }
    }

    add(row) {
        const orderId = this.recordId;
        if (orderId === undefined || orderId == '' || orderId.substring(0, 3) != '801') { 
            // if orderId is not null or if record id is not of order
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Order Id paramether missing',
                    message: 'You can\'t add product to Order. Order Id is missing.',
                    variant: 'error',
                })
            );
        } else { // create / update orderItem
            addOrderItem({orderId: orderId, product: row}).
            then(() => {
                // send event to lighning message service
                publish(this.messageContext, topChannel, {});
            })
            .catch(error => {
                this.error = error;
            });
        }
    }

}