
trigger SuperheroMissionTrigger on Superhero_Mission__c (after insert) {
    List<Id> guildIds = new List<Id>();

    for (Superhero_Mission__c mission : Trigger.new) {
        guildIds.add(mission.Guild__c);
    }

    Database.executeBatch(new SendNewMissionNotificationEmailBatch(guildIds));
}