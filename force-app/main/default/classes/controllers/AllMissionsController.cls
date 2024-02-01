public without sharing class AllMissionsController {
    private static final String COMPLEXITY_RANK_API_NAME = 'Complexity_Rank__c';
    private static final String SUBJECT_API_NAME = 'Subject__c';
    private static final String STATUS_API_NAME = 'Status__c';

    @AuraEnabled
    public static AllMissionsDTO getMissions() {
        SObjectType superheroMissionSObjectType = Superhero_Mission__c.getSObjectType();
        Map<String, SObjectField> superheroMissionSObjectFieldsMap = superheroMissionSObjectType.getDescribe().fields.getMap();

        DescribeFieldResult complexityRankFieldDescribe = superheroMissionSObjectFieldsMap.get(COMPLEXITY_RANK_API_NAME).getDescribe();
        DescribeFieldResult subjectFieldDescribe = superheroMissionSObjectFieldsMap.get(SUBJECT_API_NAME).getDescribe();
        DescribeFieldResult statusFieldDescribe = superheroMissionSObjectFieldsMap.get(STATUS_API_NAME).getDescribe();

        List<AllMissionsTableHeaderDTO> allMissionsTableHeaders = new List<AllMissionsTableHeaderDTO> {
                new AllMissionsTableHeaderDTO(Label.ALL_MISSIONS_RANK, complexityRankFieldDescribe.getName()),
                new AllMissionsTableHeaderDTO(Label.ALL_MISSIONS_MSSION, subjectFieldDescribe.getName()),
                new AllMissionsTableHeaderDTO(Label.ALL_MISSIONS_GUILD, Label.ALL_MISSIONS_GUILD),
                new AllMissionsTableHeaderDTO(Label.ALL_MISSIONS_STATUS, statusFieldDescribe.getName())
        };


        Id currentUserId = UserInfo.getUserId();
        Hero__c hero = [SELECT Guild__c, OwnerId FROM Hero__c WHERE OwnerId = :currentUserId LIMIT 1];
        Id guildId = hero.Guild__c;
        Id heroId = hero.Id;
        List<Superhero_Mission__c> superheroMissions = [SELECT Name, Is_Public__c, CreatedDate, Details__c, Guild__r.Name,
                Complexity_Rank__c, Status__c, Subject__c, (SELECT Status__c FROM Mission_Assignments__r
                WHERE Hero__c = :heroId) FROM Superhero_Mission__c WHERE Guild__c = :guildId OR
                Is_Public__c = TRUE ORDER BY CreatedDate DESC];
        AllMissionsDTO allMissionsDTO = new AllMissionsDTO(allMissionsTableHeaders, superheroMissions);

        return allMissionsDTO;
    }
}