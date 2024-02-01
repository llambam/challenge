
public with sharing class SuperheroMissionService {

//    private static final String EMAIL_SUBJECT = 'New Superhero Mission Created';
//    private static final String EMAIL_BODY = 'A new superhero mission has been created. Check it out!';
//
//    public static void notifyGuildMembers(List<Id> guildIds) {
//        List<String> guildEmails = new List<String>();
//
//
//        SObjectType superheroMissionSObjectType = Superhero_Mission__c.getSObjectType();
//        Map<String, SObjectField> superheroMissionSObjectFieldsMap = superheroMissionSObjectType.getDescribe().fields.getMap();
//
//        DescribeFieldResult complexityRankFieldDescribe = superheroMissionSObjectFieldsMap.get('Complexity_Rank__c').getDescribe();
//        DescribeFieldResult subjectFieldDescribe = superheroMissionSObjectFieldsMap.get('Subject__c').getDescribe();
//        DescribeFieldResult statusFieldDescribe = superheroMissionSObjectFieldsMap.get('Status__c').getDescribe();
//
//
//        List<AllMissionsTableHeaderDTO> allMissionsTableHeaders = new List<AllMissionsTableHeaderDTO> {
//                new AllMissionsTableHeaderDTO(Label.ALL_MISSIONS_RANK, complexityRankFieldDescribe.getName()),
//                new AllMissionsTableHeaderDTO(Label.ALL_MISSIONS_MSSION, subjectFieldDescribe.getName()),
//                new AllMissionsTableHeaderDTO(Label.ALL_MISSIONS_GUILD, Label.ALL_MISSIONS_GUILD),
//                new AllMissionsTableHeaderDTO(Label.ALL_MISSIONS_STATUS, statusFieldDescribe.getName())
//        };
//
//
//        for (Hero__c hero : [SELECT Name, Contact__r.Email  FROM Hero__c WHERE Guild__c IN :guildIds]) {
//            guildEmails.add(hero.Contact__r.Email);
//        }
//
//        if (!guildEmails.isEmpty()) {
//            EmailService.sendEmail(guildEmails, EMAIL_SUBJECT, EMAIL_BODY);
//        }
//    }
}