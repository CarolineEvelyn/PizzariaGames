trigger Service on Lead (after insert) {
    public static void newMenu (String Name, Decimal Price, String Description){
        Menu__c menu = new Menu__c();

        menu.add(
        Name = 'Frango Catupiry', 
        Price__c = 25.00, 
        Description__c = 'Frango, Catupiry, Milho e Orégano');

        menu.add(
        Name = 'Calabresa', 
        Price__c = 20.00,
        Description__c = 'Calabresa, Cebola e Orégano');

        menu.add(
        Name = 'Portuguesa',
        Price__c = 22.00,
        Description__c = 'Presunto, Ovo, Cebola, Milho e Orégano');

        menu.add(
        Name = '4 Queijos',
        Price__c = 28.00,
        Description__c = 'Mussarela, Catupiry, Parmesão e Gorgonzola');

        menu.add(
        Name = 'Bacon',
        Price__c = 30.00,
        Description__c = 'Bacon, Queijo, Cebola e Orégano');

        insert menu;
       }
        public static List<Menu__c> getMenu() {
        return [SELECT Name, Price__c, Description__c FROM Menu__c];
          if (String.isBlank(Name)) {
            System.debug('Error: por favor preencha o sabor que você deseja!');
            return null;
        }   
    }
}