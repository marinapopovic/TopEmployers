# TopEmployers - Manage Order app

Manage order app can be used to add and remove products to an order. It consists of 2 LWC components, Product List and OrderItemList.
Product List component shows all avaialble products with active pricebook entry in standard pricebook. By default it shows first 50 products, and by scrolling it loads more products. It allows adding products to order one by one.
Product OrderItemList component displays all items available. Component also shows order total and subtotals by product family. In addition, it allows for deletion of order items which triggers the recalculation of order total and subtotal.

# Project configuration and deployment
In order to be able to work on this code in your local environment you will have to setup a few things. 

Firstly, open terminal app, navigate to the directory where you keep your salesforce projects, and clone the repository 

```
git clone git@github.com:marinapopovic/TopEmployers.git
```

After the repository is successfully cloned, open the project folder in Visual Studio Code. Once the Salesforce extensions are all correctly configured proceed with authorizing your Salesforce Org.

This can be done directly through the [Visual studio code](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_auth_web.htm) or by running a command in terminal.

```
sfdx force:auth:web:login --setalias youralias --instanceurl https://login.salesforce.com --setdefaultusername
```

After the org is authorised the code can be deployed either by right clicking on force-app folder and selecting `SFDX: Deploy Source to Org` or by running a command:
```
sfdx force:source:deploy --sourcepath "force-app/main/default"
```

Once this is successfully deployed you can go Setup > Object Manager > Order object > Page layouts. Edit Order layout and add Manage Order button to the page. Now when you create a new Order, you can click Manage order button and use the page. 

