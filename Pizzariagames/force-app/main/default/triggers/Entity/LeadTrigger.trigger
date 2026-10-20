trigger LeadTrigger on Lead (before insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            Set<String> firstNames = new Set<String>();
            Set<String> lastNames = new Set<String>();
            Set<String> phones = new Set<String>();

            for(Lead lead : Trigger.new){
                if(String.isBlank(lead.FirstName) || String.isBlank(lead.LastName) || String.isBlank(lead.Phone)){
                    lead.addError('Error: Algum campo obrigatório esta vazio, por favor preencha todos os campos.');
                }

                firstNames.add(lead.FirstName);
                lastNames.add(lead.LastName);
                phones.add(lead.Phone);
            }

            List<Lead> duplicateLeads = new List<Lead>([SELECT Id, FirstName, LastName, Phone  FROM Lead WHERE FirstName IN: firstNames AND LastName IN: lastNames AND Phone IN: phones]);
            Map<String, Lead> mapLeadByKey = new Map<String, Lead>();

            for(Lead lead : duplicateLeads){
                String key = lead.FirstName + '_' + lead.LastName + '_' + lead.Phone;
                
                mapLeadByKey.put(key, lead);
            }

            for(Lead lead : Trigger.new){
                String key = lead.FirstName + '_' + lead.LastName + '_' + lead.Phone;

                if(mapLeadByKey.containsKey(key)) {
                    lead.addError('Error: Lead já existe com os mesmos dados.');
                }
            }
        }
    }
}