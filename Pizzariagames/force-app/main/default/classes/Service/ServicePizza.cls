public class ServicePizza {
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getMenu() {
        List<PricebookEntry> allPizzas = [SELECT Product2.Id, Product2.Name, Product2.Description, UnitPrice FROM PricebookEntry WHERE Product2.isActive = true AND Product2.Family = 'Pizzas'];
        return allPizzas;
    }

    @AuraEnabled
    public static Id orderPizza(Id pizzaId, Id clientId){    
        if (clientId.getSObjectType() == Lead.sObjectType) {
            Database.LeadConvert leadConvert = new Database.LeadConvert();
            leadConvert.setLeadId(clientId);
            
            LeadStatus converterStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            leadConvert.setConvertedStatus(converterStatus.MasterLabel);
            leadConvert.setDoNotCreateOpportunity(true);
            
            Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
            
            clientId = leadConvertResult.getAccountId();
        }
        
        try{
            Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

            Opportunity newOpp = new Opportunity(
                Name = 'Pedido de Pizza', 
                StageName = 'Em Andamento',
                CloseDate = System.today(),
                AccountId = clientId,
                Pricebook2Id = pricebook.Id
            );

            insert newOpp;
            processPizza(pizzaId, newOpp);
            return newOpp.Id;
        } catch(Exception e) {
            throw new AuraHandledException('Erro ao processar: ' + e.getMessage());        
        }
    }

    public static void processPizza(Id productId, Opportunity newOpp){
        
        try{
            if(productId == null){
                System.debug('Error: produto nulo');
                return;
            }

            PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id = :productId AND Pricebook2Id =: newOpp.Pricebook2Id LIMIT 1];   
            
            OpportunityLineItem newOppLineItem = new OpportunityLineItem(
                OpportunityId = newOpp.Id,
                PricebookEntryId = pricebookEntry.Id,
                UnitPrice = 10,
                Quantity = 1
            );

            insert newOppLineItem;
        }catch(Exception ex) {
            System.debug('Error: adição de produto '+ ex.getMessage());
        }
    } 
}


 