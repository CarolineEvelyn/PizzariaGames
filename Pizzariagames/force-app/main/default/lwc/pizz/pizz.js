import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import newClient from '@salesforce/apex/LeadCliente.newClient';
import getMenu from '@salesforce/apex/ServicePizza.getMenu';
import Toast from 'lightning/toast';
import orderPizza from '@salesforce/apex/ServicePizza.orderPizza';

export default class Pizz extends NavigationMixin(LightningElement) {
    firstName;
    lastName;
    phone;
    stage = 1;
    leadId;

    showSpinner = false;

    @wire(getMenu)
    menu;

    get firstStage() {
        return this.stage == 1;
    }

    get secondStage() {
        return this.stage == 2;
    }

    handleChangeFisrtName(event) {
        this.firstName = event.target.value;
    }

    handleChangeLastName(event) {
        this.lastName = event.target.value;
    }

    handleChangePhone(event) {
        this.phone = event.target.value;
    }

    async handleSaveClient(event) {
        this.showSpinner = true;

        try {
            this.leadId = await newClient({
                firstName: this.firstName,
                lastName: this.lastName,
                phone: this.phone
            });

            console.log(this.leadId);

            Toast.show(
                {
                    label: 'Cliente salvo com sucesso!',
                    variant: 'success'
                },
                this,
            );

            this.stage = 2;

        } catch (ex) {
            Toast.show(
                {
                    label: 'Ocorreu um problema',
                    message: ex.body.message,
                    variant: 'error'
                },
                this,
            );
        }

        this.showSpinner = false;
    }

    description = '';
    price = '';

    get options() {
        let newOptions = [];

        for (let pricebookEntry of this.menu.data || []) {
            newOptions.push({
                label: pricebookEntry.Product2.Name,
                description: pricebookEntry.Product2.Description,
                value: pricebookEntry.Product2.Id,
                price: pricebookEntry.UnitPrice
            });
        }

        return newOptions;
    }


    handleChangeSelect(event) {
        this.selectedProductId = event.detail.value;

        const selectedProduct = this.options.find(item => item.value === this.selectedProductId);

        this.price = selectedProduct.price;
        this.description = selectedProduct.description;
    }

    selectedProductId;

    async handleSaveFlavor(event) {
        try {

            const opportunityId = await orderPizza({
                pizzaId: this.selectedProductId,
                clientId: this.leadId
            });

            // Navigate to the Account home page
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: opportunityId,
                    actionName: "view",
                },
            });

            Toast.show(
                {
                    label: 'Pedido Salvo com sucesso!',
                    variant: 'success'
                },
                this,
            );

            this.stage = 3;

        } catch (e) {
            console.error(e);
            Toast.show(
                {
                    label: 'Ocorreu um problema',
                    message: e.body.message,
                    variant: 'error'
                },
                this,
            );
        };
    }
}




