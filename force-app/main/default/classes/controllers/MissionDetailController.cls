public without sharing class MissionDetailController {

    private static final String MISSION_COMPLETED_STATUS = 'Completed';
    private static final String MISSION_FAILED_STATUS = 'Failed';
    private static final String MISSION_IN_PROGRESS_STATUS = 'In Progress';
    private static final String EMAIL_SUBJECT = 'Your mission completed!';
    private static final String EMAIL_BODY = 'A superhero mission has been completed. Check it out!';
    private static final String NULL_PARAMETER_EXCEPTION = 'Null parameter passed to the method';
    private static final String LOW_RANK_EXCEPTION = 'Hero rank is too low';
    private static final String SIMULTANEOUS_MISSION_EXCEPTION = 'Hero cant do more than 3 missions';
    private static final Integer SIMULTANEOUS_MISSION_LIMIT = 3;
    private static final Integer AVAILABLE_MISSION_OVERLEVEL = 1;

    @AuraEnabled
    public static MissionDetailDTO getMissionDetails(final String missionId) {
        shouldNotBeNull(missionId);

        SObjectType superheroMissionSObjectType = Superhero_Mission__c.getSObjectType();
        Map<String, SObjectField> superheroMissionSObjectFieldsMap = superheroMissionSObjectType.getDescribe().fields.getMap();

        DescribeFieldResult subjectFieldDescribe = superheroMissionSObjectFieldsMap.get('Subject__c').getDescribe();
        DescribeFieldResult detailsFieldDescribe = superheroMissionSObjectFieldsMap.get('Details__c').getDescribe();
        DescribeFieldResult rewardFieldDescribe = superheroMissionSObjectFieldsMap.get('Reward__c').getDescribe();
        DescribeFieldResult deadlineFieldDescribe = superheroMissionSObjectFieldsMap.get('Deadline__c').getDescribe();

        Superhero_Mission__c superheroMissions = [SELECT Id, Complexity_Rank__c, Deadline__c, Is_Public__c, Reward__c, Subject__c, Details__c FROM Superhero_Mission__c WHERE Id = :missionId LIMIT 1];
        MissionDetailDTO missionDetailDTO = new MissionDetailDTO(
                subjectFieldDescribe.getLabel(),
                detailsFieldDescribe.getLabel(),
                Label.ALL_MISSIONS_RANK,
                rewardFieldDescribe.getLabel(),
                deadlineFieldDescribe.getLabel(),
                superheroMissions
        );

        return missionDetailDTO;
    }

    @AuraEnabled
    public static void acceptMission(String missionId) {
        shouldNotBeNull(missionId);
        Id currentUserId = UserInfo.getUserId();
        Hero__c hero = [SELECT Id, Name, Rank__c, Guild__c, OwnerId, (SELECT Id, Status__c FROM Mission_Assignments__r) FROM Hero__c WHERE OwnerId = :currentUserId LIMIT 1];
        Superhero_Mission__c superheroMission = [SELECT Id, Name, Is_Public__c, CreatedDate, Details__c, Guild__r.Name, Complexity_Rank__c, Status__c FROM Superhero_Mission__c WHERE Id = :missionId LIMIT 1];

        heroRankValidation(hero.Rank__c, superheroMission.Complexity_Rank__c);
        simultaneousMissionsValidation(hero.Mission_Assignments__r);

        insert createMissionAssignmentObject(hero, superheroMission);

        superheroMission.Status__c = MISSION_IN_PROGRESS_STATUS;
        update superheroMission;
    }

    private static Mission_Assignment__c createMissionAssignmentObject(Hero__c hero, Superhero_Mission__c superheroMission) {
        Mission_Assignment__c missionAssignment = new Mission_Assignment__c();
        missionAssignment.OwnerId = hero.OwnerId;
        missionAssignment.Hero__c = hero.Id;
        missionAssignment.Mission__c = superheroMission.Id;
        missionAssignment.Status__c = MISSION_IN_PROGRESS_STATUS;

        return missionAssignment;
    }

    private static Integer rankToInteger(String rank) {
        Map<String, Integer> rankMap = new Map<String, Integer>{
                'S' => 1, 'A' => 2, 'B' => 3, 'C' => 4, 'D' => 5
        };

        return rankMap.get(rank);
    }

    private static void heroRankValidation(String heroRank, String superheroMissionRank) {
        Integer superheroMissionRankIndex = rankToInteger(superheroMissionRank);
        Integer heroRankIndex = rankToInteger(heroRank);

        if (Math.abs(superheroMissionRankIndex - heroRankIndex) > AVAILABLE_MISSION_OVERLEVEL) {
            throw new AuraHandledException(LOW_RANK_EXCEPTION);
        }
    }

    private static void simultaneousMissionsValidation(List<Mission_Assignment__c> missionAssignments) {
        Integer numberOfUnfinishedMissions = 0;
        for (Mission_Assignment__c missionAssignment : missionAssignments) {
            if (missionAssignment.Status__c.equals(MISSION_IN_PROGRESS_STATUS)) {
                numberOfUnfinishedMissions++;
            }
        }

        if (numberOfUnfinishedMissions > SIMULTANEOUS_MISSION_LIMIT) {
            throw new AuraHandledException(SIMULTANEOUS_MISSION_EXCEPTION);
        }
    }

    @AuraEnabled
    public static void completeMission(final String missionId) {
        shouldNotBeNull(missionId);

        Id currentUserId = UserInfo.getUserId();
        List<Mission_Assignment__c> missionAssignments = [SELECT Name, Status__c, OwnerId, Hero__r.OwnerId, Hero__r.Contact__r.Email, Mission__r.Status__c FROM Mission_Assignment__c WHERE Mission__c = :missionId];
        Superhero_Mission__c superheroMission = [SELECT Status__c FROM Superhero_Mission__c WHERE Id = :missionId];

        System.debug('currentUserId ' + currentUserId);
        System.debug('missionAssignments ' + missionAssignments);
        System.debug('superheroMission ' + superheroMission);
        List<String> ownerEmails = new List<String>();

        for (Mission_Assignment__c missionAssignment : missionAssignments) {
            if (missionAssignment.Hero__r.OwnerId == currentUserId) {
                missionAssignment.Status__c = MISSION_COMPLETED_STATUS;
                missionAssignment.Mission__r.Status__c = MISSION_COMPLETED_STATUS;
                ownerEmails.add(missionAssignment.Hero__r.Contact__r.Email);
            } else {
                missionAssignment.Status__c = MISSION_FAILED_STATUS;
            }
        }

        superheroMission.Status__c = MISSION_COMPLETED_STATUS;
        EmailService.sendEmail(ownerEmails, EMAIL_SUBJECT, EMAIL_BODY);
        System.debug(missionAssignments);

        update missionAssignments;
        update superheroMission;
    }

    private static void shouldNotBeNull(Object parameter) {
        if(parameter == null) {
            throw new ContractViolationException(NULL_PARAMETER_EXCEPTION);
        }
    }
}