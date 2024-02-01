public without sharing class AllMissionsController {

    @AuraEnabled
    public static allMissionsDTO getMissions() {
        System.debug('1');



        SObjectType superheroMissionSObjectType = Superhero_Mission__c.getSObjectType();
        Map<String, SObjectField> superheroMissionSObjectFieldsMap = superheroMissionSObjectType.getDescribe().fields.getMap();

        DescribeFieldResult complexityRankFieldDescribe = superheroMissionSObjectFieldsMap.get('Complexity_Rank__c').getDescribe();
        DescribeFieldResult subjectFieldDescribe = superheroMissionSObjectFieldsMap.get('Subject__c').getDescribe();
        DescribeFieldResult statusFieldDescribe = superheroMissionSObjectFieldsMap.get('Status__c').getDescribe();


        List<AllMissionsTableHeaderDTO> allMissionsTableHeaders = new List<AllMissionsTableHeaderDTO> {
                new AllMissionsTableHeaderDTO('Rank', complexityRankFieldDescribe.getName()),
                new AllMissionsTableHeaderDTO('Mission', subjectFieldDescribe.getName()),
                new AllMissionsTableHeaderDTO('Guild', 'GuildName'),
                new AllMissionsTableHeaderDTO('Status', statusFieldDescribe.getName())
        };

        List<Superhero_Mission__c> superheroMissions = [SELECT Name, Is_Public__c, CreatedDate, Details__c, Guild__r.Name, Complexity_Rank__c, Status__c, Subject__c FROM Superhero_Mission__c ORDER BY CreatedDate DESC];

        AllMissionsDTO allMissionsDTO = new AllMissionsDTO(allMissionsTableHeaders, superheroMissions);

        return allMissionsDTO;
    }

    @AuraEnabled
    public static void updateMissionStatus(String missionId, String newStatus) {
        Superhero_Mission__c mission = [SELECT Id FROM Superhero_Mission__c WHERE Id = :missionId LIMIT 1];

        // Your logic to update mission status
        // For example, update the mission status to the new status
//        mission.Status__c = newStatus;
        update mission;
    }
}