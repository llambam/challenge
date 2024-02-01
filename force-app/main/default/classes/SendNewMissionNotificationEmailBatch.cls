public with sharing class SendNewMissionNotificationEmailBatch implements Database.Batchable<SObject>, Database.Stateful {
    private List<Id> guildIds;
    private static final String EMAIL_SUBJECT = 'New Superhero Mission Created';
    private static final String EMAIL_BODY = 'A new superhero mission has been created. Check it out!';
    private static final String QUERY = 'SELECT Name, Contact__r.Email  FROM Hero__c WHERE Guild__c IN :guildIds';


    public SendNewMissionNotificationEmailBatch(List<Id> guildIds) {
        this.guildIds = guildIds;
    }

    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        return Database.getQueryLocator(QUERY);
    }

    public void execute(Database.BatchableContext BC, List<Hero__c> heroes) {
        List<String> guildEmails = new List<String>();
        for (Hero__c hero : heroes) {
            guildEmails.add(hero.Contact__r.Email);
        }
        EmailService.sendEmail(guildEmails, EMAIL_SUBJECT, EMAIL_BODY);
    }

    public void finish(Database.BatchableContext BC) {
    }

}