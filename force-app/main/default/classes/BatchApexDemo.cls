public class BatchApexDemo implements Database.Batchable<sObject>, Database.Stateful{
    
    Integer recordsProcessed = 0;
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        return Database.getQueryLocator('SELECT Id, Customer_Start_Date__c, Customer_End_Date__c FROM Account');
    }
    
    public void execute(Database.BatchableContext bc, List<Account> accList){
        
        List<Subscription__c> subList = [SELECT Account__c, Start_Date__c, End_Date__c FROM Subscription__c WHERE Account__c IN : accList];
        List<Billing__c> billingList = [SELECT Account__c, Start_Date__c, End_Date__c FROM Billing__c WHERE Account__c IN : accList];
        
        Map<Id, Date> accToStartDate = new Map<Id, Date>();
        Map<Id, Date> accToEndDate = new Map<Id, Date>();
        
        //To enter earliest start date, latest end date in a map of Account to Start Date for Subscription
        for(Subscription__c sub : subList){
            if(accToStartDate.containsKey(sub.Account__c)){
                if(sub.Start_Date__c < accToStartDate.get(sub.Account__c)){
                    
                    accToStartDate.put(sub.Account__c, sub.Start_Date__c);
                }
            }else{
                accToStartDate.put(sub.Account__c, sub.Start_Date__c);
            }
            
            if(accToEndDate.containsKey(sub.Account__c)){
                if(sub.End_Date__c > accToEndDate.get(sub.Account__c)){
                    accToEndDate.put(sub.Account__c, sub.End_Date__c);
                }
            }else{
                accToEndDate.put(sub.Account__c, sub.End_Date__c);
            }
            
            
        }   
        
        //To enter earliest start date, latest end date in a map of Account to Start Date for Billing
        for(Billing__c bil : billingList){
            
            if(accToStartDate.containsKey(bil.Account__c)){
                if(bil.Start_Date__c < accToStartDate.get(bil.Account__c)){
                    
                    accToStartDate.put(bil.Account__c, bil.Start_Date__c);
                }
            }else{
                
                accToStartDate.put(bil.Account__c, bil.Start_Date__c);
            }
            
            if(accToEndDate.containsKey(bil.Account__c)){
                if(bil.End_Date__c > accToEndDate.get(bil.Account__c)){
                    accToEndDate.put(bil.Account__c, bil.End_Date__c);
                }
            }else{
                accToEndDate.put(bil.Account__c, bil.End_Date__c);
            }
        }
        
        //Update Account fields
        for(Account acc : accList){
            if(accToStartDate.containsKey(acc.Id)){
                acc.Customer_Start_Date__c = accToStartDate.get(acc.Id);
            }
            if(accToEndDate.containsKey(acc.Id)){
                acc.Customer_End_Date__c = accToEndDate.get(acc.Id);
            }
        }
        recordsProcessed++;
        update accList;
        
        
    }
    
    public void finish(Database.BatchableContext bc){
        
        System.debug(recordsProcessed);
        
    }
}