public class LeadCliente {
    @AuraEnabled(cacheable=false)
    public static Id newClient(String firstName, String lastName, String phone){
        if (String.isBlank(firstName) || String.isBlank(lastName) || String.isBlank(phone)) {
            throw new AuraHandledException('Error: Algum campo obrigatório esta vazio, por favor preencha todos os campos.');
        }

        try{
            List<Lead> leadlist = [SELECT Id FROM Lead WHERE FirstName = :firstName AND LastName = :lastName AND Phone = :phone];
            if (!leadlist.isEmpty()) {
                System.debug('Error: Lead já existe com os mesmos dados.');
                Lead foundLead = leadlist[0];
                return foundLead.Id;
            }

            String accountname = firstName + ' ' + lastName; 

            List<Account> accountlist = [SELECT Id FROM Account WHERE Name = :accountname AND Phone = :phone];
            if (!accountlist.isEmpty()) {
                System.debug('Error: Conta já existe com os mesmos dados.');
                Account foundAccount = accountlist[0];
                return foundAccount.Id;
            }

            Lead newLead = new Lead(
                FirstName = firstName,
                LastName = lastName,
                Phone = phone,
                Company = 'Cliente'
            
            ); 

            insert newLead;
            return newLead.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
}